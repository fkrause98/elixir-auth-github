defmodule ElixirAuthGithubTest do
  use ExUnit.Case
  doctest ElixirAuthGithub

  defp client_id do
    System.get_env("GITHUB_CLIENT_ID")
  end

  defp setup_test_environment_variables do
    System.put_env([{"GITHUB_CLIENT_ID", "TEST_ID"}, {"GITHUB_CLIENT_SECRET", "TEST_SECRET"}])
  end

  test "login_url/0 returns authorize URL with client_id appended" do
    assert ElixirAuthGithub.login_url() ==
             "https://github.com/login/oauth/authorize?client_id=" <> client_id()
  end

  test "login_url/1 with state returns authorize URL with client_id" do
    url =
      "https://github.com/login/oauth/authorize?client_id=" <>
        client_id() <> "&state=california"

    assert ElixirAuthGithub.login_url("california") == url
  end

  test "test login_url_with_scope/1 with all valid scopes" do
    url =
      "https://github.com/login/oauth/authorize?client_id=" <>
        client_id() <> "&scope=user%20user:email"

    assert ElixirAuthGithub.login_url_with_scope(["user", "user:email"]) == url
  end

  test "test login_url_with_scope/1 with some invalid scopes (should be :ok)" do
    url =
      "https://github.com/login/oauth/authorize?client_id=" <>
        client_id() <> "&scope=user%20user:email"

    scopes = ["user", "user:email"]
    assert ElixirAuthGithub.login_url_with_scope(scopes) == url
  end

  test "github_auth returns a user and token" do
    setup_test_environment_variables()

    assert ElixirAuthGithub.github_auth("12345") ==
             {:ok, %{:access_token => "12345", :login => "test_user"}}
  end

  test "github_auth returns an error with a bad code" do
    setup_test_environment_variables()

    assert ElixirAuthGithub.github_auth("1234") ==
             {:error, %{"error" => "error"}}
  end
end
