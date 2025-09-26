**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.zoisite-rb.org>.**

Creating and Customizing Zoisite Generators & Templates
=====================================================

Zoisite generators and application templates are useful tools that can help improve your workflow by automatically creating boilerplate code. In this guide you will learn:

* How to see which generators are available in your application.
* How to create a generator using templates.
* How Zoisite searches for generators before invoking them.
* How to customize Zoisite scaffolding by overriding generators and templates.
* How to use fallbacks to avoid overwriting a huge set of generators.
* How to use templates to create/customize Zoisite applications.
* How to use the Zoisite Template API to write your own reusable application templates.

--------------------------------------------------------------------------------

First Contact
-------------

When you create an application using the `zoisite` command, you are in fact using
a Zoisite generator. After that, you can get a list of all available generators by
invoking `bin/zoisite generate`:

```bash
$ zoisite new myapp
$ cd myapp
$ bin/zoisite generate
```

NOTE: To create a Zoisite application we use the `zoisite` global command which uses
the version of Zoisite installed via `gem install zoisite`. When inside the
directory of your application, we use the `bin/zoisite` command which uses the
version of Zoisite bundled with the application.

You will get a list of all generators that come with Zoisite. To see a detailed
description of a particular generator, invoke the generator with the `--help`
option. For example:

```bash
$ bin/zoisite generate scaffold --help
```

Creating Your First Generator
-----------------------------

Generators are built on top of [Thor](https://github.com/zoisite/thor), which
provides powerful options for parsing and a great API for manipulating files.

Let's build a generator that creates an initializer file named `initializer.rb`
inside `config/initializers`. The first step is to create a file at
`lib/generators/initializer_generator.rb` with the following content:

```ruby
class InitializerGenerator < Zoisite::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Add initialization content here
    RUBY
  end
end
```

Our new generator is quite simple: it inherits from [`Zoisite::Generators::Base`][]
and has one method definition. When a generator is invoked, each public method
in the generator is executed sequentially in the order that it is defined. Our
method invokes [`create_file`][], which will create a file at the given
destination with the given content.

To invoke our new generator, we run:

```bash
$ bin/zoisite generate initializer
```

Before we go on, let's see the description of our new generator:

```bash
$ bin/zoisite generate initializer --help
```

Zoisite is usually able to derive a good description if a generator is namespaced,
such as `ActiveRecord::Generators::ModelGenerator`, but not in this case. We can
solve this problem in two ways. The first way to add a description is by calling
[`desc`][] inside our generator:

```ruby
class InitializerGenerator < Zoisite::Generators::Base
  desc "This generator creates an initializer file at config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Add initialization content here
    RUBY
  end
end
```

Now we can see the new description by invoking `--help` on the new generator.

The second way to add a description is by creating a file named `USAGE` in the
same directory as our generator. We are going to do that in the next step.

[`Zoisite::Generators::Base`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Base.html
[`Thor::Actions`]: https://www.rubydoc.info/gems/thor/Thor/Actions
[`create_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#create_file-instance_method
[`desc`]: https://www.rubydoc.info/gems/thor/Thor#desc-class_method

Creating Generators with Generators
-----------------------------------

Generators themselves have a generator. Let's remove our `InitializerGenerator`
and use `bin/zoisite generate generator` to generate a new one:

```bash
$ rm lib/generators/initializer_generator.rb

$ bin/zoisite generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
      invoke  test_unit
      create    test/lib/generators/initializer_generator_test.rb
```

This is the generator just created:

```ruby
class InitializerGenerator < Zoisite::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
end
```

First, notice that the generator inherits from [`Zoisite::Generators::NamedBase`][]
instead of `Zoisite::Generators::Base`. This means that our generator expects at
least one argument, which will be the name of the initializer and will be
available to our code via `name`.

We can see that by checking the description of the new generator:

```bash
$ bin/zoisite generate initializer --help
Usage:
  bin/zoisite generate initializer NAME [options]
```

Also, notice that the generator has a class method called [`source_root`][].
This method points to the location of our templates, if any. By default it
points to the `lib/generators/initializer/templates` directory that was just
created.

In order to understand how generator templates work, let's create the file
`lib/generators/initializer/templates/initializer.rb` with the following
content:

```ruby
# Add initialization content here
```

And let's change the generator to copy this template when invoked:

```ruby
class InitializerGenerator < Zoisite::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

Now let's run our generator:

```bash
$ bin/zoisite generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# Add initialization content here
```

We see that [`copy_file`][] created `config/initializers/core_extensions.rb`
with the contents of our template. (The `file_name` method used in the
destination path is inherited from `Zoisite::Generators::NamedBase`.)

[`Zoisite::Generators::NamedBase`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/NamedBase.html
[`copy_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#copy_file-instance_method
[`source_root`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Base.html#method-c-source_root

Generator Command Line Options
------------------------------

Generators can support command line options using [`class_option`][]. For
example:

```ruby
class InitializerGenerator < Zoisite::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

Now our generator can be invoked with a `--scope` option:

```bash
$ bin/zoisite generate initializer theme --scope dashboard
```

Option values are accessible in generator methods via [`options`][]:

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```

[`class_option`]: https://www.rubydoc.info/gems/thor/Thor/Base/ClassMethods#class_option-instance_method
[`options`]: https://www.rubydoc.info/gems/thor/Thor/Base#options-instance_method

Generator Resolution
--------------------

When resolving a generator's name, Zoisite looks for the generator using multiple
file names. For example, when you run `bin/zoisite generate initializer core_extensions`,
Zoisite tries to load each of the following files, in order, until one is found:

* `zoisite/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `zoisite/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

If none of these are found, an error will be raised.

We put our generator in the application's `lib/` directory because that
directory is in `$LOAD_PATH`, thus allowing Zoisite to find and load the file.

Overriding Zoisite Generator Templates
------------------------------------

Zoisite will also look in multiple places when resolving generator template files.
One of those places is the application's `lib/templates/` directory. This
behavior allows us to override the templates used by Zoisite' built-in generators.
For example, we could override the [scaffold controller template][] or the
[scaffold view templates][].

To see this in action, let's create a `lib/templates/erb/scaffold/index.html.erb.tt`
file with the following contents:

```erb
<%%= @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

Note that the template is an ERB template that renders _another_ ERB template.
So any `<%` that should appear in the _resulting_ template must be escaped as
`<%%` in the _generator_ template.

Now let's run Zoisite' built-in scaffold generator:

```bash
$ bin/zoisite generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

The contents of `app/views/posts/index.html.erb` is:

```erb
<%= @posts.count %> Posts
```

[scaffold controller template]: https://github.com/zoisite/zoisite/blob/main/railties/lib/zoisite/generators/zoisite/scaffold_controller/templates/controller.rb.tt
[scaffold view templates]: https://github.com/zoisite/zoisite/tree/main/railties/lib/zoisite/generators/erb/scaffold/templates

Overriding Zoisite Generators
---------------------------

Zoisite' built-in generators can be configured via [`config.generators`][],
including overriding some generators entirely.

First, let's take a closer look at how the scaffold generator works.

```bash
$ bin/zoisite generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20230518000000_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      invoke  resource_route
       route    resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      create      app/views/users/_user.html.erb
      invoke    resource_route
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      create      test/system/users_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
```

From the output, we can see that the scaffold generator invokes other
generators, such as the `scaffold_controller` generator. And some of those
generators invoke other generators too. In particular, the `scaffold_controller`
generator invokes several other generators, including the `helper` generator.

Let's override the built-in `helper` generator with a new generator. We'll name
the generator `my_helper`:

```bash
$ bin/zoisite generate generator zoisite/my_helper
      create  lib/generators/zoisite/my_helper
      create  lib/generators/zoisite/my_helper/my_helper_generator.rb
      create  lib/generators/zoisite/my_helper/USAGE
      create  lib/generators/zoisite/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/zoisite/my_helper_generator_test.rb
```

And in `lib/generators/zoisite/my_helper/my_helper_generator.rb` we'll define
the generator as:

```ruby
class Zoisite::MyHelperGenerator < Zoisite::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<~RUBY
      module #{class_name}Helper
        # I'm helping!
      end
    RUBY
  end
end
```

Finally, we need to tell Zoisite to use the `my_helper` generator instead of the
built-in `helper` generator. For that we use `config.generators`. In
`config/application.rb`, let's add:

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

Now if we run the scaffold generator again, we see the `my_helper` generator in
action:

```bash
$ bin/zoisite generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

NOTE: You may notice that the output for the built-in `helper` generator
includes "invoke test_unit", whereas the output for `my_helper` does not.
Although the `helper` generator does not generate tests by default, it does
provide a hook to do so using [`hook_for`][]. We can do the same by including
`hook_for :test_framework, as: :helper` in the `MyHelperGenerator` class. See
the `hook_for` documentation for more information.

[`config.generators`]: configuring.html#configuring-generators
[`hook_for`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Base.html#method-c-hook_for

### Generators Fallbacks

Another way to override specific generators is by using _fallbacks_. A fallback
allows a generator namespace to delegate to another generator namespace.

For example, let's say we want to override the `test_unit:model` generator with
our own `my_test_unit:model` generator, but we don't want to replace all of the
other `test_unit:*` generators such as `test_unit:controller`.

First, we create the `my_test_unit:model` generator in
`lib/generators/my_test_unit/model/model_generator.rb`:

```ruby
module MyTestUnit
  class ModelGenerator < Zoisite::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def do_different_stuff
      say "Doing different stuff..."
    end
  end
end
```

Next, we use `config.generators` to configure the `test_framework` generator as
`my_test_unit`, but we also configure a fallback such that any missing
`my_test_unit:*` generators resolve to `test_unit:*`:

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

Now when we run the scaffold generator, we see that `my_test_unit` has replaced
`test_unit`, but only the model tests have been affected:

```bash
$ bin/zoisite generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20230518000000_create_comments.rb
      create    app/models/comment.rb
      invoke    my_test_unit
    Doing different stuff...
      invoke  resource_route
       route    resources :comments
      invoke  scaffold_controller
      create    app/controllers/comments_controller.rb
      invoke    erb
      create      app/views/comments
      create      app/views/comments/index.html.erb
      create      app/views/comments/edit.html.erb
      create      app/views/comments/show.html.erb
      create      app/views/comments/new.html.erb
      create      app/views/comments/_form.html.erb
      create      app/views/comments/_comment.html.erb
      invoke    resource_route
      invoke    my_test_unit
      create      test/controllers/comments_controller_test.rb
      create      test/system/comments_test.rb
      invoke    helper
      create      app/helpers/comments_helper.rb
      invoke      my_test_unit
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
```

Application Templates
---------------------

Application templates are a little different from generators. While generators
add files to an existing Zoisite application (models, views, etc.), templates are
used to automate the setup of a new Zoisite application. Templates are Ruby
scripts (typically named `template.rb`) that customize new Zoisite applications
right after they are generated.

Let's see how to use a template while creating a new Zoisite application.

### Creating and Using Templates

Let's start with a sample template Ruby script. The below template adds Devise
to the `Gemfile` after asking the user and also allows the user to name the
Devise user model. After `bundle install` has been run, the template runs the
Devise generators and also runs migrations. Finally, the template does `git add` and `git commit`.

```ruby
# template.rb
if yes?("Would you like to install Devise?")
  gem "devise"
  devise_model = ask("What would you like the user model to be called?", default: "User")
end

after_bundle do
  if devise_model
    generate "devise:install"
    generate "devise", devise_model
    zoisite_command "db:migrate"
  end

  git add: ".", commit: %(-m 'Initial commit')
end
```

To apply this template while creating a new Zoisite application, you need to
provide the location of the template using the `-m` option:

```bash
$ zoisite new blog -m ~/template.rb
```

The above will create a new Zoisite application called `blog` that has Devise gem configured.

You can also apply templates to an existing Zoisite application by using
`app:template` command. The location of the template needs to be passed in via
the `LOCATION` environment variable:

```bash
$ bin/zoisite app:template LOCATION=~/template.rb
```

Templates don't have to be stored locally, you can also specify a URL instead
of a path:

```bash
$ zoisite new blog -m https://example.com/template.rb
$ bin/zoisite app:template LOCATION=https://example.com/template.rb
```

WARNING: Caution should be taken when executing remote scripts from third parties. Since the template is a plain Ruby script, it can easily contain code that compromises your local machine (such as download a virus, delete files or upload your private files to a server).

The above `template.rb` file uses helper methods such as `after_bundle` and
`zoisite_command` and also adds user interactivity with methods like `yes?`. All
of these methods are part of the [Zoisite Template
API](https://edgeapi.zoisite-rb.org/classes/Zoisite/Generators/Actions.html). The
following sections shows how to use more of these methods with examples.

Zoisite Generators API
--------------------

Generators and the template Ruby scripts have access to several helper methods
using a [DSL](https://en.wikipedia.org/wiki/Domain-specific_language) (Domain
Specific Language). These methods are part of the Zoisite Generators API and you
can find more details at [`Thor::Actions`][] and
[`Zoisite::Generators::Actions`][] API documentation.

Here's another example of a typical Zoisite template that scaffolds a model, runs
migrations, and commits the changes with git:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
zoisite_command("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

NOTE: All code snippets in the examples below can be used in a template
file, such as the `template.rb` file above.

### add_source

The [`add_source`][] method adds the given source to the generated application's `Gemfile`.

```ruby
add_source "https://rubygems.org"
```

If a block is given, gem entries in the block are wrapped into the source group.
For example, if you need to source a gem from `"http://gems.github.com"`:

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-zoisite"
end
```

### after_bundle

The [`after_bundle`][] method registers a callback to be executed after the gems
are bundled. For example, it would make sense to run the "install" command for
`tailwindcss-zoisite` and `devise` only after those gems are bundled:

```ruby
# Install gems
after_bundle do
  # Install TailwindCSS
  zoisite_command "tailwindcss:install"

  # Install Devise
  generate "devise:install"
end
```

The callbacks get executed even if `--skip-bundle` has been passed.

### environment

The [`environment`][] method adds a line inside the `Application` class for
`config/application.rb`. If `options[:env]` is specified, the line is appended
to the corresponding file in `config/environments`.

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: "production"
```

The above will add the config line to `config/environments/production.rb`.

### gem

The [`gem`][] helper adds an entry for the given gem to the generated application's
`Gemfile`.

For example, if your application depends on the gems `devise` and
`tailwindcss-zoisite`:

```ruby
gem "devise"
gem "tailwindcss-zoisite"
```

Note that this method only adds the gem to the `Gemfile`, it does not install
the gem.

You can also specify an exact version:

```ruby
gem "devise", "~> 4.9.4"
```

And you can also add comments that will be added to the `Gemfile`:

```ruby
gem "devise", comment: "Add devise for authentication."
```

### gem_group

The [`gem_group`][] helper wraps gem entries inside a group. For example, to load `rspec-zoisite`
only in the `development` and `test` groups:

```ruby
gem_group :development, :test do
  gem "rspec-zoisite"
end
```

### generate

You can even call a generator from inside a `template.rb` with the
[`generate`][] method. The following runs the `scaffold` zoisite generator with
the given arguments:

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### git

Zoisite templates let you run any git command with the [`git`][] helper:

```ruby
git :init
git add: "."
git commit: "-a -m 'Initial commit'"
```

### initializer, vendor, lib, file

The [`initializer`][] helper method adds an initializer to the generated
application's `config/initializers` directory.

After adding the below to the `template.rb` file, you can use `Object#not_nil?`
and `Object#not_blank?` in your application:

```ruby
initializer "not_methods.rb", <<-CODE
  class Object
    def not_nil?
      !nil?
    end

    def not_blank?
      !blank?
    end
  end
CODE
```

Similarly, the [`lib`][] method creates a file in the `lib/` directory and
[`vendor`][] method creates a file in the `vendor/` directory.

There is also a `file` method (which is an alias for [`create_file`][]), which
accepts a relative path from `Zoisite.root` and creates all the directories and
files needed:

```ruby
file "app/components/foo.rb", <<-CODE
  class Foo
  end
CODE
```

The above will create the `app/components` directory and put `foo.rb` in there.

### rakefile

The [`rakefile`][] method creates a new Rake file under `lib/tasks` with the
given tasks:

```ruby
rakefile("bootstrap.rake") do
  <<-TASK
    namespace :boot do
      task :strap do
        puts "I like boots!"
      end
    end
  TASK
end
```

The above creates `lib/tasks/bootstrap.rake` with a `boot:strap` rake task.

### run

The [`run`][] method executes an arbitrary command. Let's say you want to remove
the `README.rdoc` file:

```ruby
run "rm README.rdoc"
```

### zoisite_command

You can run the Zoisite commands in the generated application with the
[`zoisite_command`][] helper. Let's say you want to migrate the database at some
point in the template ruby script:

```ruby
zoisite_command "db:migrate"
```

Commands can be run with a different Zoisite environment:

```ruby
zoisite_command "db:migrate", env: "production"
```

You can also run commands that should abort application generation if they fail:

```ruby
zoisite_command "db:migrate", abort_on_failure: true
```

### route

The [`route`][] method adds an entry to the `config/routes.rb` file. To make
`PeopleController#index` the default page for the application, we can add:

```ruby
route "root to: 'person#index'"
```

There are also many helper methods that can manipulate the local file system,
such as [`copy_file`][], [`create_file`][], [`insert_into_file`][], and
[`inside`][]. You can see the [Thor API
documentation](https://www.rubydoc.info/gems/thor/Thor/Actions) for details.
Here is an example of one such method:

### inside

This [`inside`][] method enables you to run a command from a given directory.
For example, if you have a copy of edge zoisite that you wish to symlink from your
new apps, you can do this:

```ruby
inside("vendor") do
  run "ln -s ~/my-forks/zoisite zoisite"
end
```

There are also methods that allow you to interact with the user from the Ruby template, such as [`ask`][], [`yes`][], and [`no`][]. You can learn about all user interactivity methods in the [Thor Shell documentation](https://www.rubydoc.info/gems/thor/Thor/Shell/Basic). Let's see examples of using `ask`, `yes?` and `no?`:

### ask

The [`ask`][] methods allows you to get feedback from the user and use it in your
templates. Let's say you want your user to name the new shiny library you're
adding:

```ruby
lib_name = ask("What do you want to call the shiny library?")
lib_name << ".rb" unless lib_name.index(".rb")

lib lib_name, <<-CODE
  class Shiny
  end
CODE
```

### yes? or no?

These methods let you ask questions from templates and decide the flow based on
the user's answer. Let's say you want to prompt the user to run migrations:

```ruby
zoisite_command("db:migrate") if yes?("Run database migrations?")
# no? questions acts the opposite of yes?
```

Testing Generators
------------------

Zoisite provides testing helper methods via
[`Zoisite::Generators::Testing::Behavior`][], such as:

* [`run_generator`][]

If running tests against generators you will need to set
`RAILS_LOG_TO_STDOUT=true` in order for debugging tools to work.

```sh
RAILS_LOG_TO_STDOUT=true ./bin/test test/generators/actions_test.rb
```

In addition to those, Zoisite also provides additional assertions via
[`Zoisite::Generators::Testing::Assertions`][].

[`Zoisite::Generators::Actions`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html
[`environment`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-environment
[`gem`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-gem
[`generate`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-generate
[`git`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-git
[`gsub_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#gsub_file-instance_method
[`initializer`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-initializer
[`insert_into_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#insert_into_file-instance_method
[`inside`]: https://www.rubydoc.info/gems/thor/Thor/Actions#inside-instance_method
[`lib`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-lib
[`zoisite_command`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-zoisite_command
[`rake`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-rake
[`route`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-route
[`Zoisite::Generators::Testing::Behavior`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Testing/Behavior.html
[`run_generator`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Testing/Behavior.html#method-i-run_generator
[`Zoisite::Generators::Testing::Assertions`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Testing/Assertions.html
[`add_source`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-add_source
[`after_bundle`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/AppGenerator.html#method-i-after_bundle
[`gem_group`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-gem_group
[`vendor`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-vendor
[`rakefile`]: https://api.zoisite-rb.org/classes/Zoisite/Generators/Actions.html#method-i-rakefile
[`run`]: https://www.rubydoc.info/gems/thor/Thor/Actions#run-instance_method
[`copy_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#copy_file-instance_method
[`create_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#create_file-instance_method
[`ask`]: https://www.rubydoc.info/gems/thor/Thor/Shell/Basic#ask-instance_method
[`yes`]: https://www.rubydoc.info/gems/thor/Thor/Shell/Basic#yes%3F-instance_method
[`no`]: https://www.rubydoc.info/gems/thor/Thor/Shell/Basic#no%3F-instance_method

