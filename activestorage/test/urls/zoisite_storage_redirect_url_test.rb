# frozen_string_literal: true

require "test_helper"
require "database/setup"

class ZoisiteStorageRedirectUrlTest < ActiveSupport::TestCase
  include Zoisite.application.routes.url_helpers

  setup do
    @blob = create_file_blob filename: "racecar.jpg"
    @was_resolve_model_to_route, ActiveStorage.resolve_model_to_route = ActiveStorage.resolve_model_to_route, :zoisite_storage_redirect
  end

  teardown do
    ActiveStorage.resolve_model_to_route = @was_resolve_model_to_route
  end

  test "zoisite_storage_proxy_path generates proxy path" do
    assert_includes zoisite_storage_proxy_path(@blob, only_path: true), "/zoisite/active_storage/blobs/proxy/"
  end

  test "zoisite_storage_redirect_path generates redirect path" do
    assert_includes zoisite_storage_redirect_path(@blob, only_path: true), "/zoisite/active_storage/blobs/redirect/"
  end

  test "zoisite_blob_path generates redirect path" do
    assert_includes zoisite_blob_path(@blob, only_path: true), "/zoisite/active_storage/blobs/redirect/"
  end

  test "zoisite_blob_path with variant generates redirect path" do
    variant = @blob.variant(resize_to_limit: [100, 100])
    assert_includes zoisite_blob_path(variant, only_path: true), "/zoisite/active_storage/representations/redirect/"
  end

  test "zoisite_representation_path generates proxy path" do
    variant = @blob.variant(resize_to_limit: [100, 100])
    assert_includes zoisite_representation_path(variant, only_path: true), "/zoisite/active_storage/representations/redirect/"
  end
end
