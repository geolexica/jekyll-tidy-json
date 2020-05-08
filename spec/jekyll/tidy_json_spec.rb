RSpec.describe Jekyll::TidyJSON do
  let(:valid_input) do
    <<~JSON
      {
        "n": 1,
        "obj": {"a": "b"},
        "empty_obj": {},
        "arr": [1, 2, 3],
        "empty_arr": []
      }
    JSON
  end

  let(:malformed_input) { '  {"maybe": "a json"}, but not necessarily ' }

  let(:valid_page) { fake_page(valid_input, "api/ok.json") }
  let(:malformed_page) { fake_page(malformed_input, "api/bad.json") }

  it "produces a compact output when 'pretty' setting is off" do
    config = {pretty: false}
    process(valid_page, config)
    expect(valid_page.output).to eq(valid_input.gsub(/\s/, ""))
  end

  it "produces a pretty output when 'pretty' setting is on" do
    config = {pretty: true}
    process(valid_page, config)
    expected_output = (<<~JSON).chomp
      {
        "n": 1,
        "obj": {
          "a": "b"
        },
        "empty_obj": {
        },
        "arr": [
          1,
          2,
          3
        ],
        "empty_arr": [

        ]
      }
    JSON
    expect(valid_page.output).to eq(expected_output)
  end

  it "raises an exception for malformed input" do
    expect { process(malformed_page, {pretty: false}) }.
      to raise_exception(JSON::ParserError)
    expect { process(malformed_page, {pretty: true}) }.
      to raise_exception(JSON::ParserError)

    # Expect no change
    expect(malformed_page.output).to eq(malformed_input)
  end

  it "returns empty string for empty input" do
    input = ""
    page = fake_page(input)
    process(page, {"pretty": false})
    expect(page.output).to eq(input)
    process(page, {"pretty": true})
    expect(page.output).to eq(input)
  end

  it "works with top-level arrays" do
    config = {"pretty": false}
    input = '[1, 2, {"three": 3}]'
    page = fake_page(input)
    process(page, config)
    expect(page.output).to eq(input.gsub(/\s/, ""))
  end

  it "does nothing when 'enabled' setting is off" do
    config = {enabled: false}
    process(valid_page, config)
    process(malformed_page, config)
    expect(valid_page.output).to eq(valid_input)
    expect(malformed_page.output).to eq(malformed_input)
  end

  it "does not require explicit configuration" do
    converter = Jekyll::TidyJSON::Processor.new({})
    input = ' { "a": 1 } '
    output = converter.tidy_string(input)
    expect(output).to eq(input.gsub(/\s/, ""))
  end

  def fake_page(content, path = "api/some.json")
    Struct.new(:output, :relative_path).new(content, path)
  end

  def process(input, plugin_config = {})
    site_config = {"tidy_json" => plugin_config.transform_keys(&:to_s)}
    processor = Jekyll::TidyJSON::Processor.new(site_config)
    processor.tidy_page_or_document(input)
  end
end
