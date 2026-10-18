# frozen_string_literal: true

namespace :prompt_system do
  desc 'Load LocalID Account'

  task load_account_vid: :environment do

    url = "#{ENV['Local_ID_BASE_URL']}/api/v1/users"
    response = HTTParty.get(url, body: { service_id: ENV['SERVICE_ID'] }.to_json, headers: { 'Content-Type': 'application/json'})

    user_lists = response.dig('users')
    return if user_lists.empty?

    user_lists.each do |user|
      prompt_system_user = User.find_by(email: user.dig('email'))
      next if prompt_system_user.present?

      company = Company.find_by(v_company_uid: user.dig('company_uid'))
      if company.blank?
        company = Company.create!(
          name: user.dig('company_name'),
          address: user.dig('company_address'),
          company_type: user.dig('company_type'),
          v_company_uid: user.dig('company_uid')
        )
      end
      User.create(
        email: user.dig('email'),
        password: 'Aa@123456',
        name: user.dig('name'),
        role: user.dig('role') == 'admin' ? :admin : :member,
        company_id: company.id,
        phone: user.dig('phone'),
        gender: user.dig('gender')
      )
    end
    puts 'Load success!'
  end
end
