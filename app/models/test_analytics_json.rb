TEST_ANALYTICS_JSON = {
  "history" => YAML.load_file('data/test_analytics_json_fields_history.yaml'),
  "span" => YAML.load_file('data/test_analytics_json_fields_span.yaml'),
  "test_result" => YAML.load_file('data/test_analytics_json_fields_test_result.yaml')
}.freeze
