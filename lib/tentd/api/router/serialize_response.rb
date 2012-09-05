require 'json'

module TentD
  class API
    module Router
      class SerializeResponse
        def call(env)
          response = if env.response
            env.response.kind_of?(String) ? env.response : env.response.to_json(serialization_options(env))
          end
          status = env['response.status'] || (response ? 200 : 404)
          headers = if env['response.type'] || status == 200 && response && !response.empty?
                      { 'Content-Type' => env['response.type'] || MEDIA_TYPE } 
                    else
                      {}
                    end
          [status, headers, [response.to_s]]
        end

        private

        def serialization_options(env)
          options = {}
          options[:app] = env.current_auth.kind_of?(Model::AppAuthorization)
          options[:permissions] = env.authorized_scopes.include?(:read_permissions)
          options[:groups] = env.authorized_scopes.include?(:read_groups)
          options[:mac] = env.authorized_scopes.include?(:read_secrets)
          options[:self] = env.authorized_scopes.include?(:self)
          options
        end
      end
    end
  end
end
