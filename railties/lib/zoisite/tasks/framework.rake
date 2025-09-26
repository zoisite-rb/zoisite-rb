# frozen_string_literal: true

namespace :app do
  desc "Apply the template supplied by LOCATION=(/path/to/template) or URL"
  task template: :environment do
    template = ENV["LOCATION"]
    raise "No LOCATION value given. Please set LOCATION either as path to a file or a URL" if template.blank?
    require "zoisite/generators"
    require "zoisite/generators/zoisite/app/app_generator"
    Zoisite::Generators::AppGenerator.apply_zoisite_template(template, Zoisite.root)
  end

  namespace :templates do
    # desc "Copy all the templates from zoisite to the application directory for customization. Already existing local copies will be overwritten"
    task :copy do
      generators_lib = File.expand_path("../generators", __dir__)
      project_templates = "#{Zoisite.root}/lib/templates"

      default_templates = { "erb"   => %w{controller mailer scaffold},
                            "zoisite" => %w{controller helper scaffold_controller} }

      default_templates.each do |type, names|
        local_template_type_dir = File.join(project_templates, type)
        mkdir_p local_template_type_dir, verbose: false

        names.each do |name|
          dst_name = File.join(local_template_type_dir, name)
          src_name = File.join(generators_lib, type, name, "templates")
          cp_r src_name, dst_name, verbose: false
        end
      end
    end
  end
end
