import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory
from threading import Thread
import unittest


class MarkdownAccessTest(unittest.TestCase):
    def run_eval(self, *, home_status=200, redirect_pipelines=False,
                 setup_guide="getting-started", pipelines_type="text/markdown", truncate_pipelines=False):
        class DocsHandler(BaseHTTPRequestHandler):
            def do_GET(self):
                accept = self.headers.get("Accept")
                if self.path == "/docs" and accept == "text/markdown":
                    if home_status is not None:
                        self.respond(home_status, "# Home\n[Pipelines](https://example.com/docs/pipelines.md)")
                elif self.path == "/docs/pipelines.md" and redirect_pipelines:
                    self.send_response(302)
                    self.send_header("Location", "/docs/pipelines")
                    self.end_headers()
                elif (self.path, accept) in (("/docs/pipelines.md", None), ("/docs/pipelines", "text/markdown")):
                    self.respond(200, f"# Pipelines\n[Start](https://example.com/docs/pipelines/{setup_guide}.md)",
                                 pipelines_type, truncated=truncate_pipelines and self.path.endswith(".md"))
                else:
                    self.respond(200, "<html>Not Markdown</html>", "text/html")

            def respond(self, status, body, content_type="text/markdown", *, truncated=False):
                payload = body.encode()
                self.send_response(status)
                self.send_header("Content-Type", content_type)
                self.send_header("Content-Length", str(len(payload) + int(truncated)))
                self.end_headers()
                self.wfile.write(payload)

            def log_message(self, *_):
                pass

        with ThreadingHTTPServer(("127.0.0.1", 0), DocsHandler) as server, TemporaryDirectory() as output:
            thread = Thread(target=server.serve_forever)
            thread.start()
            try:
                result = subprocess.run([
                    sys.executable, str(Path(__file__).with_name("run.py")), "docs",
                    "--base-url", f"http://127.0.0.1:{server.server_port}", "--source", "test", "--out", output,
                ], capture_output=True, text=True, timeout=10)
            finally:
                server.shutdown()
                thread.join()
            self.assertIn("### Agent access", result.stdout, result.stderr)
            report = json.loads((Path(output) / "report.json").read_text())
            return result, report["cases"]["markdown-onboarding"]["checks"]

    def test_checks_both_markdown_access_paths_without_gating_reader_scores(self):
        result, checks = self.run_eval()
        self.assertEqual(result.returncode, 0)
        self.assertIn("**markdown-onboarding**: passed", result.stdout)
        self.assertEqual([check["passed"] for check in checks], [True, True])

    def test_fails_on_redirect_non_200_or_wrong_content_type(self):
        for options, failure_index, status in (
            ({"redirect_pipelines": True}, 1, 302),
            ({"home_status": 500}, 0, 500),
            ({"home_status": 201}, 0, 201),
            ({"pipelines_type": "text/html"}, 1, 200),
        ):
            with self.subTest(status=status):
                result, checks = self.run_eval(**options)
                self.assertEqual(result.returncode, 1)
                self.assertIn("**markdown-onboarding**: failed", result.stdout)
                self.assertIs(checks[failure_index]["passed"], False)
                self.assertEqual(checks[failure_index]["page"]["status"], status)

    def test_reports_changed_setup_link_without_failing_the_eval(self):
        result, checks = self.run_eval(setup_guide="new-setup-guide")
        self.assertEqual(result.returncode, 0)
        self.assertIn("**markdown-onboarding**: content mismatch (informational)", result.stdout)
        self.assertEqual([check["passed"] for check in checks], [True, False])

    def test_connection_failure_does_not_hide_a_confirmed_failure(self):
        for redirect_pipelines, exit_code, status in ((False, 0, "not run"), (True, 1, "failed")):
            with self.subTest(redirect_pipelines=redirect_pipelines):
                result, checks = self.run_eval(home_status=None, redirect_pipelines=redirect_pipelines)
                self.assertEqual(result.returncode, exit_code)
                self.assertIn(f"**markdown-onboarding**: {status}", result.stdout)
                self.assertIsNone(checks[0]["passed"])

    def test_truncated_markdown_response_is_not_checked(self):
        result, checks = self.run_eval(truncate_pipelines=True)
        self.assertEqual(result.returncode, 0)
        self.assertIn("**markdown-onboarding**: not run", result.stdout)
        self.assertEqual([check["passed"] for check in checks], [True, None])
