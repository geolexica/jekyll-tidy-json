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

  it "produces a compact output when 'pretty' setting is off" do
    config = {pretty: false}
    output = process(valid_input, config)
    expect(output).to eq(valid_input.gsub(/\s/, ""))
  end

  it "produces a pretty output when 'pretty' setting is on" do
    config = {pretty: true}
    output = process(valid_input, config)
    expected_output = valid_input
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
    expect(output).to eq(expected_output)
  end

  it "raises an exception for malformed input" do
    expect { process(malformed_input, {pretty: false}) }.
      to raise_exception(JSON::ParserError)
    expect { process(malformed_input, {pretty: true}) }.
      to raise_exception(JSON::ParserError)
  end

  it "returns empty string for empty input" do
    input = ""
    output_compact = process(input, {"pretty": false})
    output_pretty = process(input, {"pretty": true})
    expect(output_compact).to eq(input)
    expect(output_pretty).to eq(input)
  end

  it "works with top-level arrays" do
    config = {"pretty": false}
    input = '[1, 2, {"three": 3}]'
    output = process(input, config)
    expect(output).to eq(input.gsub(/\s/, ""))
  end

  it "does nothing when 'enabled' setting is off" do
    config = {enabled: false}
    output1 = process(valid_input, config)
    output2 = process(malformed_input, config)
    expect(output1).to eq(valid_input)
    expect(output2).to eq(malformed_input)
  end

  it "does not require explicit configuration" do
    converter = Jekyll::TidyJSON::Processor.new({})
    input = ' { "a": 1 } '
    output = converter.tidy_string(input)
    expect(output).to eq(input.gsub(/\s/, ""))
  end

  def process(input, plugin_config = {})
    site_config = {"tidy_json" => plugin_config.transform_keys(&:to_s)}
    processor = Jekyll::TidyJSON::Processor.new(site_config)
    processor.tidy_string(input)
  end
end
