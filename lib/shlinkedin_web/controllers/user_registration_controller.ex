defmodule ShlinkedinWeb.UserRegistrationController do
  use ShlinkedinWeb, :controller

  alias Shlinkedin.Accounts
  alias Shlinkedin.Accounts.User
  alias ShlinkedinWeb.UserAuth

  def join(conn, %{"ref" => slug}) do
    case Shlinkedin.Profiles.get_profile_by_slug(slug) do
      nil ->
        render(conn, "join.html", persona_name: nil, real_name: nil)

      profile ->
        render(conn, "join.html", persona_name: profile.persona_name, real_name: profile.real_name)
    end
  end

  def join(conn, _params) do
    render(conn, "join.html", persona_name: nil, real_name: nil)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :confirm, &1)
          )

        conn
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
