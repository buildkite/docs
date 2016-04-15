import React from "react";

class Page extends React.Component {
  render() {
    let path = this.props.path.replace(/[^a-zA-Z0-9\-\/]/g, "").replace(/\-/g, "_");
    let sourceURL = "https://github.com/buildkite/docs/blob/master/pages/" + path + ".md";

    try {
      return (
        <div className="Docs__article">
          <section dangerouslySetInnerHTML={{ __html: require("../../pages/" + path + ".md") }} />

          <div className="Docs__note">
            <p>Spotted a typo? Something missing? Please <a href="https://github.com/buildkite/docs/issues">open an issue</a> or <a href={sourceURL}>contribute an update</a>.</p>
          </div>
        </div>
      );
    } catch(e) {
      return (
        <section>{path} not found</section>
      );
    }
  }
}

export default Page;
