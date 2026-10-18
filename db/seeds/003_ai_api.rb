return if AiApi.count >= 1

AiApi.create(name: "V1/Completion", model_list: ["text-davinci-003", "text-davinci-002", "text-curie-001", "text-babbage-001", "text-ada-001"], ai_api_input_fields_attributes: [{ name: 'prompt', type: "string or array", default_value: "Say this is a test" }, { name: "max_tokens", type: "integer", default_value: 16 }, { name: "temperature", type: "float", default_value: 1 }, { name: "top_p", type: "float", default_value: 1 }, { name: "n", type: "integer", default_value: 1 }, { name: "stream", type: "boolean", default_value: "false" }, { name: "logprobs", type: "integer", default_value: '' }, { name: "stop", type: "string", default_value: "\n" }])
AiApi.create(
  name: "V1/Chat/Completions",
  ai_type: 1,
  model_list: ["gpt-4", "gpt-4-0613", "text-curie-001", "gpt-4-32k", "gpt-4-32k-0613", "gpt-3.5-turbo", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k", "gpt-3.5-turbo-16k-0613"],
  ai_api_input_fields_attributes: [
    { name: "max_tokens", type: "integer", default_value: '' },
    { name: "temperature", type: "float", default_value: 1 },
    { name: "top_p", type: "float", default_value: 1 },
    { name: "n", type: "integer", default_value: 1 },
    { name: "stream", type: "boolean", default_value: "false" },
    { name: "stop", type: "string", default_value: "\n" }
  ])

AiApi.create(
  name: "V1/Edits",
  ai_type: 2,
  model_list: ["text-davinci-edit-001", "code-davinci-edit-001"],
  ai_api_input_fields_attributes: [
    { name: "input", type: "string", default_value: '' },
    { name: "instruction", type: "string", default_value: ''},
    { name: "n", type: "integer", default_value: 1 },
    { name: "top_p", type: "float", default_value: 1 },
    { name: "temperature", type: "float", default_value: 1 },
  ])

AiApi.create(
  name: "V1/Images/Generations",
  ai_type: 3,
  ai_api_input_fields_attributes: [
    { name: "prompt", type: "string", default_value: "" },
    { name: "n", type: "integer", default_value: 1 },
    { name: "size", type: "string", default_value: "1024x1024", options: ["256x256", "512x512", "1024x1024"] },
    { name: "response_format", type: "string", default_value: "url", options: ["url", "b64_json"] },
    { name: "user", type: "string", default_value: "" },
  ])

AiApi.create(
  name: "V1/Images/Edits",
  ai_type: 4,
  ai_api_input_fields_attributes: [
    { name: "prompt", type: "string", default_value: "" },
    { name: "n", type: "integer", default_value: 1 },
    { name: "size", type: "string", default_value: "1024x1024", options: ["256x256", "512x512", "1024x1024"] },
    { name: "response_format", type: "string", default_value: "url", options: ["url", "b64_json"] },
    { name: "user", type: "string", default_value: "" },
  ])
