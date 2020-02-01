defmodule ElixirAuthGithubTest do
  use ExUnit.Case
  doctest ElixirAuthGithub

  defp client_id do
    System.get_env("GITHUB_CLIENT_ID")
  end

  test "login_url/0 returns authorize URL with client_id appended" do
    assert ElixirAuthGithub.login_url() ==
      "https://github.com/login/oauth/authorize?client_id=" <> client_id()
  end

  test "login_url/1 with state returns authorize URL with client_id" do
    url = "https://github.com/login/oauth/authorize?client_id="
      <> client_id() <> "&state=california"

    assert ElixirAuthGithub.login_url("california") == url
  end

  test "github_auth returns a user and token" do
    Application.put_env :elixir_auth_github, :client_id, "TEST_ID"
    Application.put_env :elixir_auth_github, :client_secret, "TEST_SECRET"

    assert ElixirAuthGithub.github_auth("12345") == {:ok, %{"access_token" => "12345", "login" => "test_user"}}
  end

  test "github_auth returns an error with a bad code" do
    Application.put_env :elixir_auth_github, :client_id, "TEST_ID"
    Application.put_env :elixir_auth_github, :client_secret, "TEST_SECRET"

    assert ElixirAuthGithub.github_auth("1234") == {:error, %{"error" => "error"}}
  end

  test "test" do
    Application.put_env :elixir_auth_github, :client_id, "TEST_ID"
    Application.put_env :elixir_auth_github, :client_secret, "TEST_SECRET"

    assert ElixirAuthGithub.github_auth("123") == {:error, %{"error" => "test error"}}
  end

  test "Test github auth with state" do
    Application.put_env :elixir_auth_github, :client_id, "TEST_ID"
    Application.put_env :elixir_auth_github, :client_secret, "TEST_SECRET"

    assert ElixirAuthGithub.github_auth("12345", "hello") == {:ok, %{"access_token" => "12345", "login" => "test_user", "state" => "hello"}}
  end

  test "test github auth failure with state" do
    Application.put_env :elixir_auth_github, :client_id, "TEST_ID"
    Application.put_env :elixir_auth_github, :client_secret, "TEST_SECRET"

    assert ElixirAuthGithub.github_auth("1234", "hello") == {:error, %{"error" => "error"}}
  end

  test "test login_url_with_scope/1 with all valid scopes" do
    url = "https://github.com/login/oauth/authorize?client_id="
      <> client_id() <> "&scope=user%20user:email"

    assert ElixirAuthGithub.login_url_with_scope(["user", "user:email"]) ==
      {:ok, url}
  end

  test "test login_url_with_scope/1 with some invalid scopes (should be :ok)" do
    url = "https://github.com/login/oauth/authorize?client_id="
      <> client_id() <> "&scope=user%20user:email"
    scopes = ["user", "user:email", "other"]
    assert ElixirAuthGithub.login_url_with_scope(scopes) == {:ok, url}
  end


  test "test login_url_with_scope/2 with all valid inputs" do
    url = "https://github.com/login/oauth/authorize?client_id="
      <> client_id() <> "&scope=user%20user:email&state=hello"

    assert ElixirAuthGithub.login_url_with_scope(["user", "user:email"], "hello")
      == {:ok, url}
  end

  test "test login_url_with_scope/2 with no valid scopes" do
    Application.put_env :elixir_auth_github, :client_id, "TEST_ID"

    assert ElixirAuthGithub.login_url_with_scope(["other"], "hello") == {:err, "no valid scopes provided"}
  end
end
