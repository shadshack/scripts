# Set your API key and endpoint
# Get your API key here - https://platform.openai.com/account/api-keys
$apiKey = "..."

# Set the endpoint for chatgpt
# https://platform.openai.com/docs/api-reference/chat/create
$endpoint = "https://api.openai.com/v1/chat/completions"

# Set the headers
$headers = @{
  "Content-Type"  = "application/json"
  "Authorization" = "Bearer $apiKey"
}

while ($true) {
  # Set the prompt
  $prompt = Read-Host "Enter your prompt"

  # Set API options
  # List models with below command:
  # (Invoke-RestMethod -Method Get -Uri https://api.openai.com/v1/models -Headers $headers).data.id
  $options = @"
{
  "model": "gpt-3.5-turbo",
  "messages": [{"role": "user", "content": "$prompt"}],
  "temperature": 0.7
}
"@

  # Invoke the ChatGPT API
  # Invoke-RestMethod -Method Post -Uri $endpoint -Headers $headers -Body $options
  $response = Invoke-RestMethod -Method Post -Uri $endpoint -Headers $headers -Body $options


  # Print the result
  Write-Host $response.choices[0].message.content
}

