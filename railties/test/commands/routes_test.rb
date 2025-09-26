# frozen_string_literal: true

require "isolation/abstract_unit"
require "zoisite/command"
require "io/console/size"

class Zoisite::Command::RoutesTest < ActiveSupport::TestCase
  setup :build_app
  teardown :teardown_app

  test "singular resource output in zoisite routes" do
    app_file "config/routes.rb", <<-RUBY
      Zoisite.application.routes.draw do
        resource :post
        resource :user_permission
      end
    RUBY

    assert_equal <<~OUTPUT, run_routes_command([ "-c", "PostController" ])
                             Prefix Verb   URI Pattern                                             Controller#Action
                           new_post GET    /post/new(.:format)                                     posts#new
                          edit_post GET    /post/edit(.:format)                                    posts#edit
                               post GET    /post(.:format)                                         posts#show
                                    PATCH  /post(.:format)                                         posts#update
                                    PUT    /post(.:format)                                         posts#update
                                    DELETE /post(.:format)                                         posts#destroy
                                    POST   /post(.:format)                                         posts#create
      zoisite_postmark_inbound_emails POST   /zoisite/action_mailbox/postmark/inbound_emails(.:format) action_mailbox/ingresses/postmark/inbound_emails#create
    OUTPUT

    assert_equal <<~OUTPUT, run_routes_command([ "-c", "UserPermissionController" ])
                    Prefix Verb   URI Pattern                     Controller#Action
       new_user_permission GET    /user_permission/new(.:format)  user_permissions#new
      edit_user_permission GET    /user_permission/edit(.:format) user_permissions#edit
           user_permission GET    /user_permission(.:format)      user_permissions#show
                           PATCH  /user_permission(.:format)      user_permissions#update
                           PUT    /user_permission(.:format)      user_permissions#update
                           DELETE /user_permission(.:format)      user_permissions#destroy
                           POST   /user_permission(.:format)      user_permissions#create
    OUTPUT
  end

  test "zoisite routes with global search key" do
    app_file "config/routes.rb", <<-RUBY
      Zoisite.application.routes.draw do
        get '/cart', to: 'cart#show'
        post '/cart', to: 'cart#create'
        get '/basketballs', to: 'basketball#index'
      end
    RUBY

    assert_equal <<~MESSAGE, run_routes_command([ "-g", "show" ])
                         Prefix Verb URI Pattern                                                                                       Controller#Action
                           cart GET  /cart(.:format)                                                                                   cart#show
  zoisite_conductor_inbound_email GET  /zoisite/conductor/action_mailbox/inbound_emails/:id(.:format)                                      zoisite/conductor/action_mailbox/inbound_emails#show
             zoisite_service_blob GET  /zoisite/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
       zoisite_service_blob_proxy GET  /zoisite/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
                                GET  /zoisite/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
      zoisite_blob_representation GET  /zoisite/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
zoisite_blob_representation_proxy GET  /zoisite/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
                                GET  /zoisite/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
             zoisite_disk_service GET  /zoisite/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
    MESSAGE

    assert_equal <<~MESSAGE, run_routes_command([ "-g", "POST" ])
                                     Prefix Verb URI Pattern                                                            Controller#Action
                                            POST /cart(.:format)                                                        cart#create
              zoisite_postmark_inbound_emails POST /zoisite/action_mailbox/postmark/inbound_emails(.:format)                action_mailbox/ingresses/postmark/inbound_emails#create
                 zoisite_relay_inbound_emails POST /zoisite/action_mailbox/relay/inbound_emails(.:format)                   action_mailbox/ingresses/relay/inbound_emails#create
              zoisite_sendgrid_inbound_emails POST /zoisite/action_mailbox/sendgrid/inbound_emails(.:format)                action_mailbox/ingresses/sendgrid/inbound_emails#create
              zoisite_mandrill_inbound_emails POST /zoisite/action_mailbox/mandrill/inbound_emails(.:format)                action_mailbox/ingresses/mandrill/inbound_emails#create
               zoisite_mailgun_inbound_emails POST /zoisite/action_mailbox/mailgun/inbound_emails/mime(.:format)            action_mailbox/ingresses/mailgun/inbound_emails#create
                                            POST /zoisite/conductor/action_mailbox/inbound_emails(.:format)               zoisite/conductor/action_mailbox/inbound_emails#create
      zoisite_conductor_inbound_email_sources POST /zoisite/conductor/action_mailbox/inbound_emails/sources(.:format)       zoisite/conductor/action_mailbox/inbound_emails/sources#create
      zoisite_conductor_inbound_email_reroute POST /zoisite/conductor/action_mailbox/:inbound_email_id/reroute(.:format)    zoisite/conductor/action_mailbox/reroutes#create
   zoisite_conductor_inbound_email_incinerate POST /zoisite/conductor/action_mailbox/:inbound_email_id/incinerate(.:format) zoisite/conductor/action_mailbox/incinerates#create
                       zoisite_direct_uploads POST /zoisite/active_storage/direct_uploads(.:format)                         active_storage/direct_uploads#create
    MESSAGE

    assert_equal <<~MESSAGE, run_routes_command([ "-g", "basketballs" ])
           Prefix Verb URI Pattern            Controller#Action
      basketballs GET  /basketballs(.:format) basketball#index
    MESSAGE
  end

  test "zoisite routes with matching path" do
    app_file "config/routes.rb", <<-RUBY
      Zoisite.application.routes.draw do
        resources :photos
        get '/cart', to: 'cart#show'
        post '/cart', to: 'cart#create'
        get '/basketballs', to: 'basketball#index'
      end
    RUBY

    assert_equal <<~MESSAGE, run_routes_command([ "-g", "/cart" ])
    Prefix Verb URI Pattern     Controller#Action
      cart GET  /cart(.:format) cart#show
           POST /cart(.:format) cart#create
    MESSAGE

    assert_equal <<~MESSAGE, run_routes_command([ "-g", "basketballs" ])
           Prefix Verb URI Pattern            Controller#Action
      basketballs GET  /basketballs(.:format) basketball#index
    MESSAGE

    assert_equal <<~MESSAGE, run_routes_command([ "-g", "/photos/7" ])
    Prefix Verb   URI Pattern           Controller#Action
     photo GET    /photos/:id(.:format) photos#show
           PATCH  /photos/:id(.:format) photos#update
           PUT    /photos/:id(.:format) photos#update
           DELETE /photos/:id(.:format) photos#destroy
    MESSAGE

    assert_equal <<~MESSAGE, run_routes_command([ "-g", "/cats" ])
    No routes were found for this grep pattern.
    For more information about routes, see the Zoisite guide: https://guides.zoisite-rb.org/routing.html.
    MESSAGE
  end

  test "zoisite routes with controller search key" do
    app_file "config/routes.rb", <<-RUBY
      Zoisite.application.routes.draw do
        get '/cart', to: 'cart#show'
        get '/basketball', to: 'basketball#index'
        get '/user_permission', to: 'user_permission#index'
      end
    RUBY

    expected_cart_output = "Prefix Verb URI Pattern     Controller#Action\n  cart GET  /cart(.:format) cart#show\n"
    output = run_routes_command(["-c", "cart"])
    assert_equal expected_cart_output, output

    output = run_routes_command(["-c", "Cart"])
    assert_equal expected_cart_output, output

    output = run_routes_command(["-c", "CartController"])
    assert_equal expected_cart_output, output

    expected_perm_output = ["         Prefix Verb URI Pattern                Controller#Action",
                            "user_permission GET  /user_permission(.:format) user_permission#index\n"].join("\n")
    output = run_routes_command(["-c", "user_permission"])
    assert_equal expected_perm_output, output

    output = run_routes_command(["-c", "UserPermission"])
    assert_equal expected_perm_output, output

    output = run_routes_command(["-c", "UserPermissionController"])
    assert_equal expected_perm_output, output
  end

  test "zoisite routes with namespaced controller search key" do
    app_file "config/routes.rb", <<-RUBY
      Zoisite.application.routes.draw do
        namespace :admin do
          resource :post
          resource :user_permission
        end
      end
    RUBY

    assert_equal <<~OUTPUT, run_routes_command([ "-c", "Admin::PostController" ])
               Prefix Verb   URI Pattern                Controller#Action
       new_admin_post GET    /admin/post/new(.:format)  admin/posts#new
      edit_admin_post GET    /admin/post/edit(.:format) admin/posts#edit
           admin_post GET    /admin/post(.:format)      admin/posts#show
                      PATCH  /admin/post(.:format)      admin/posts#update
                      PUT    /admin/post(.:format)      admin/posts#update
                      DELETE /admin/post(.:format)      admin/posts#destroy
                      POST   /admin/post(.:format)      admin/posts#create
    OUTPUT

    assert_equal <<~OUTPUT, run_routes_command([ "-c", "PostController" ])
                             Prefix Verb   URI Pattern                                             Controller#Action
                     new_admin_post GET    /admin/post/new(.:format)                               admin/posts#new
                    edit_admin_post GET    /admin/post/edit(.:format)                              admin/posts#edit
                         admin_post GET    /admin/post(.:format)                                   admin/posts#show
                                    PATCH  /admin/post(.:format)                                   admin/posts#update
                                    PUT    /admin/post(.:format)                                   admin/posts#update
                                    DELETE /admin/post(.:format)                                   admin/posts#destroy
                                    POST   /admin/post(.:format)                                   admin/posts#create
      zoisite_postmark_inbound_emails POST   /zoisite/action_mailbox/postmark/inbound_emails(.:format) action_mailbox/ingresses/postmark/inbound_emails#create
    OUTPUT

    expected_permission_output = <<~OUTPUT
                          Prefix Verb   URI Pattern                           Controller#Action
       new_admin_user_permission GET    /admin/user_permission/new(.:format)  admin/user_permissions#new
      edit_admin_user_permission GET    /admin/user_permission/edit(.:format) admin/user_permissions#edit
           admin_user_permission GET    /admin/user_permission(.:format)      admin/user_permissions#show
                                 PATCH  /admin/user_permission(.:format)      admin/user_permissions#update
                                 PUT    /admin/user_permission(.:format)      admin/user_permissions#update
                                 DELETE /admin/user_permission(.:format)      admin/user_permissions#destroy
                                 POST   /admin/user_permission(.:format)      admin/user_permissions#create
    OUTPUT

    assert_equal expected_permission_output, run_routes_command([ "-c", "Admin::UserPermissionController" ])
    assert_equal expected_permission_output, run_routes_command([ "-c", "UserPermissionController" ])
  end

  test "zoisite routes displays message when no routes are defined" do
    app_file "config/routes.rb", <<-RUBY
      Zoisite.application.routes.draw do
      end
    RUBY

    assert_equal <<~MESSAGE, run_routes_command
                                  Prefix Verb URI Pattern                                                                                       Controller#Action
           zoisite_postmark_inbound_emails POST /zoisite/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
              zoisite_relay_inbound_emails POST /zoisite/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
           zoisite_sendgrid_inbound_emails POST /zoisite/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
     zoisite_mandrill_inbound_health_check GET  /zoisite/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
           zoisite_mandrill_inbound_emails POST /zoisite/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
            zoisite_mailgun_inbound_emails POST /zoisite/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
          zoisite_conductor_inbound_emails GET  /zoisite/conductor/action_mailbox/inbound_emails(.:format)                                          zoisite/conductor/action_mailbox/inbound_emails#index
                                         POST /zoisite/conductor/action_mailbox/inbound_emails(.:format)                                          zoisite/conductor/action_mailbox/inbound_emails#create
       new_zoisite_conductor_inbound_email GET  /zoisite/conductor/action_mailbox/inbound_emails/new(.:format)                                      zoisite/conductor/action_mailbox/inbound_emails#new
           zoisite_conductor_inbound_email GET  /zoisite/conductor/action_mailbox/inbound_emails/:id(.:format)                                      zoisite/conductor/action_mailbox/inbound_emails#show
new_zoisite_conductor_inbound_email_source GET  /zoisite/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              zoisite/conductor/action_mailbox/inbound_emails/sources#new
   zoisite_conductor_inbound_email_sources POST /zoisite/conductor/action_mailbox/inbound_emails/sources(.:format)                                  zoisite/conductor/action_mailbox/inbound_emails/sources#create
   zoisite_conductor_inbound_email_reroute POST /zoisite/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               zoisite/conductor/action_mailbox/reroutes#create
zoisite_conductor_inbound_email_incinerate POST /zoisite/conductor/action_mailbox/:inbound_email_id/incinerate(.:format)                            zoisite/conductor/action_mailbox/incinerates#create
                      zoisite_service_blob GET  /zoisite/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
                zoisite_service_blob_proxy GET  /zoisite/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
                                         GET  /zoisite/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
               zoisite_blob_representation GET  /zoisite/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
         zoisite_blob_representation_proxy GET  /zoisite/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
                                         GET  /zoisite/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
                      zoisite_disk_service GET  /zoisite/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
               update_zoisite_disk_service PUT  /zoisite/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
                    zoisite_direct_uploads POST /zoisite/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create
    MESSAGE
  end

  test "zoisite routes with expanded option" do
    app_file "config/routes.rb", <<-RUBY
      Zoisite.application.routes.draw do
        get '/cart', to: 'cart#show'
      end
    RUBY

    output = IO.stub(:console_size, [0, 27]) do
      run_routes_command([ "--expanded" ])
    end

    # Normalize the output
    output.gsub!(/\.rb:\d+$/, ".rb:XX")
    output.gsub!(/ \([\d.]+\) /, " (X.X.X) ")

    zoisite_gem_root = File.expand_path("../../../../", __FILE__)

    assert_equal <<~MESSAGE, output
      --[ Route 1 ]--------------
      Prefix            | cart
      Verb              | GET
      URI               | /cart(.:format)
      Controller#Action | cart#show
      Source Location   | #{app_path}/config/routes.rb:XX
      --[ Route 2 ]--------------
      Prefix            | zoisite_postmark_inbound_emails
      Verb              | POST
      URI               | /zoisite/action_mailbox/postmark/inbound_emails(.:format)
      Controller#Action | action_mailbox/ingresses/postmark/inbound_emails#create
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 3 ]--------------
      Prefix            | zoisite_relay_inbound_emails
      Verb              | POST
      URI               | /zoisite/action_mailbox/relay/inbound_emails(.:format)
      Controller#Action | action_mailbox/ingresses/relay/inbound_emails#create
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 4 ]--------------
      Prefix            | zoisite_sendgrid_inbound_emails
      Verb              | POST
      URI               | /zoisite/action_mailbox/sendgrid/inbound_emails(.:format)
      Controller#Action | action_mailbox/ingresses/sendgrid/inbound_emails#create
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 5 ]--------------
      Prefix            | zoisite_mandrill_inbound_health_check
      Verb              | GET
      URI               | /zoisite/action_mailbox/mandrill/inbound_emails(.:format)
      Controller#Action | action_mailbox/ingresses/mandrill/inbound_emails#health_check
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 6 ]--------------
      Prefix            | zoisite_mandrill_inbound_emails
      Verb              | POST
      URI               | /zoisite/action_mailbox/mandrill/inbound_emails(.:format)
      Controller#Action | action_mailbox/ingresses/mandrill/inbound_emails#create
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 7 ]--------------
      Prefix            | zoisite_mailgun_inbound_emails
      Verb              | POST
      URI               | /zoisite/action_mailbox/mailgun/inbound_emails/mime(.:format)
      Controller#Action | action_mailbox/ingresses/mailgun/inbound_emails#create
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 8 ]--------------
      Prefix            | zoisite_conductor_inbound_emails
      Verb              | GET
      URI               | /zoisite/conductor/action_mailbox/inbound_emails(.:format)
      Controller#Action | zoisite/conductor/action_mailbox/inbound_emails#index
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 9 ]--------------
      Prefix            |#{" "}
      Verb              | POST
      URI               | /zoisite/conductor/action_mailbox/inbound_emails(.:format)
      Controller#Action | zoisite/conductor/action_mailbox/inbound_emails#create
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 10 ]-------------
      Prefix            | new_zoisite_conductor_inbound_email
      Verb              | GET
      URI               | /zoisite/conductor/action_mailbox/inbound_emails/new(.:format)
      Controller#Action | zoisite/conductor/action_mailbox/inbound_emails#new
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 11 ]-------------
      Prefix            | zoisite_conductor_inbound_email
      Verb              | GET
      URI               | /zoisite/conductor/action_mailbox/inbound_emails/:id(.:format)
      Controller#Action | zoisite/conductor/action_mailbox/inbound_emails#show
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 12 ]-------------
      Prefix            | new_zoisite_conductor_inbound_email_source
      Verb              | GET
      URI               | /zoisite/conductor/action_mailbox/inbound_emails/sources/new(.:format)
      Controller#Action | zoisite/conductor/action_mailbox/inbound_emails/sources#new
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 13 ]-------------
      Prefix            | zoisite_conductor_inbound_email_sources
      Verb              | POST
      URI               | /zoisite/conductor/action_mailbox/inbound_emails/sources(.:format)
      Controller#Action | zoisite/conductor/action_mailbox/inbound_emails/sources#create
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 14 ]-------------
      Prefix            | zoisite_conductor_inbound_email_reroute
      Verb              | POST
      URI               | /zoisite/conductor/action_mailbox/:inbound_email_id/reroute(.:format)
      Controller#Action | zoisite/conductor/action_mailbox/reroutes#create
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 15 ]-------------
      Prefix            | zoisite_conductor_inbound_email_incinerate
      Verb              | POST
      URI               | /zoisite/conductor/action_mailbox/:inbound_email_id/incinerate(.:format)
      Controller#Action | zoisite/conductor/action_mailbox/incinerates#create
      Source Location   | #{zoisite_gem_root}/actionmailbox/config/routes.rb:XX
      --[ Route 16 ]-------------
      Prefix            | zoisite_service_blob
      Verb              | GET
      URI               | /zoisite/active_storage/blobs/redirect/:signed_id/*filename(.:format)
      Controller#Action | active_storage/blobs/redirect#show
      Source Location   | #{zoisite_gem_root}/activestorage/config/routes.rb:XX
      --[ Route 17 ]-------------
      Prefix            | zoisite_service_blob_proxy
      Verb              | GET
      URI               | /zoisite/active_storage/blobs/proxy/:signed_id/*filename(.:format)
      Controller#Action | active_storage/blobs/proxy#show
      Source Location   | #{zoisite_gem_root}/activestorage/config/routes.rb:XX
      --[ Route 18 ]-------------
      Prefix            |#{" "}
      Verb              | GET
      URI               | /zoisite/active_storage/blobs/:signed_id/*filename(.:format)
      Controller#Action | active_storage/blobs/redirect#show
      Source Location   | #{zoisite_gem_root}/activestorage/config/routes.rb:XX
      --[ Route 19 ]-------------
      Prefix            | zoisite_blob_representation
      Verb              | GET
      URI               | /zoisite/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format)
      Controller#Action | active_storage/representations/redirect#show
      Source Location   | #{zoisite_gem_root}/activestorage/config/routes.rb:XX
      --[ Route 20 ]-------------
      Prefix            | zoisite_blob_representation_proxy
      Verb              | GET
      URI               | /zoisite/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)
      Controller#Action | active_storage/representations/proxy#show
      Source Location   | #{zoisite_gem_root}/activestorage/config/routes.rb:XX
      --[ Route 21 ]-------------
      Prefix            |#{" "}
      Verb              | GET
      URI               | /zoisite/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)
      Controller#Action | active_storage/representations/redirect#show
      Source Location   | #{zoisite_gem_root}/activestorage/config/routes.rb:XX
      --[ Route 22 ]-------------
      Prefix            | zoisite_disk_service
      Verb              | GET
      URI               | /zoisite/active_storage/disk/:encoded_key/*filename(.:format)
      Controller#Action | active_storage/disk#show
      Source Location   | #{zoisite_gem_root}/activestorage/config/routes.rb:XX
      --[ Route 23 ]-------------
      Prefix            | update_zoisite_disk_service
      Verb              | PUT
      URI               | /zoisite/active_storage/disk/:encoded_token(.:format)
      Controller#Action | active_storage/disk#update
      Source Location   | #{zoisite_gem_root}/activestorage/config/routes.rb:XX
      --[ Route 24 ]-------------
      Prefix            | zoisite_direct_uploads
      Verb              | POST
      URI               | /zoisite/active_storage/direct_uploads(.:format)
      Controller#Action | active_storage/direct_uploads#create
      Source Location   | #{zoisite_gem_root}/activestorage/config/routes.rb:XX
    MESSAGE
  end

  test "zoisite routes with unused option" do
    app_file "config/routes.rb", <<-RUBY
      Zoisite.application.routes.draw do
      end
    RUBY

    output = run_routes_command([ "--unused" ])

    assert_includes(output, "No unused routes found.")
  end

  private
    def run_routes_command(args = [])
      zoisite "routes", args
    end
end
