return if Project.count >= 2

Project.create(name: 'Project 1', description: 'Project about Open AI Chat', application_domain: 'https://ai-matching.Local.net')
Project.create(name: 'Project 2', description: 'Project about Open AI Completion', application_domain: 'https://ai-matching.Local.net')
