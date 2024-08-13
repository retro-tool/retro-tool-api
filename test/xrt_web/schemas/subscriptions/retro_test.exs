defmodule XrtWeb.Schemas.Subscriptions.RetroTest do
  use XrtWeb.SubscriptionCase
  import Phoenix.ConnTest

  import Xrt.Factory
  import XrtWeb.GraphqlHelpers

  alias Xrt.Retros
  alias Xrt.Retros.Retro

  setup do
    {:ok, socket} =
      Phoenix.ChannelTest.connect(XrtWeb.UserSocket, %{
        "user_uuid" => "user-uuid"
      })

    {:ok, socket} = join_absinthe(socket)

    %{socket: socket}
  end

  @trigger """
    mutation createWorksItem($slug: String!, $title: String!) {
      createWorksItem(retro_slug: $slug, title: $title) {
        id
      }
    }
  """

  defp add_item(retro) do
    %{"data" => %{"createWorksItem" => %{"id" => item_id}}} =
      build_conn()
      |> run(@trigger, %{slug: retro.slug, title: "This works great"})
      |> json_response(200)

    item_id
  end

  describe "retroUpdated" do
    @subscription """
      subscription retroUpdated($slug: String!) {
        retroUpdated(slug: $slug) {
          slug
          works {
            id
          }
        }
      }
    """

    setup do
      %{retro: insert(:retro)}
    end

    test "pushes an update when a `works` item is added in the retro", %{
      socket: socket,
      retro: retro
    } do
      ref = push_doc(socket, @subscription, variables: %{slug: retro.slug})
      assert_reply(ref, :ok, %{subscriptionId: __subscription_id})

      item_id = add_item(retro)
      retro_slug = retro.slug

      assert_push("subscription:data", %{
        result: %{
          data: %{
            "retroUpdated" => %{
              "slug" => ^retro_slug,
              "works" => [%{"id" => ^item_id}]
            }
          }
        }
      })
    end

    test "doesn't push an update when a `works` item is added to another the retro", %{
      socket: socket,
      retro: retro
    } do
      other_retro = insert(:retro)
      ref = push_doc(socket, @subscription, variables: %{slug: retro.slug})
      assert_reply(ref, :ok, %{subscriptionId: _subscription_id})

      add_item(other_retro)

      retro_slug = retro.slug

      refute_push("subscription:data", %{
        result: %{data: %{"retroUpdated" => %{"slug" => ^retro_slug}}}
      })
    end
  end

  describe "retroUpdated with password" do
    @subscription """
      subscription retroUpdated($slug: String!, $password: String) {
        retroUpdated(slug: $slug, password: $password) {
          slug
          works {
            id
          }
        }
      }
    """

    setup do
      %{retro: insert(:retro, password_hash: Retro.encrypt_password("password"))}
    end

    test "pushes an update when subscribing with the right password", %{
      socket: socket,
      retro: retro
    } do
      ref = push_doc(socket, @subscription, variables: %{slug: retro.slug, password: "password"})
      assert_reply(ref, :ok, %{subscriptionId: _subscription_id})

      item_id = add_item(retro)

      retro_slug = retro.slug

      assert_push("subscription:data", %{
        result: %{
          data: %{
            "retroUpdated" => %{"slug" => ^retro_slug, "works" => [%{"id" => ^item_id}]}
          }
        }
      })
    end

    test "can't subscribe with the wrong password", %{socket: socket, retro: retro} do
      ref =
        push_doc(socket, @subscription,
          variables: %{slug: retro.slug, password: "wrong-password"}
        )

      assert_reply(ref, :error, %{
        errors: [%{message: %{extensions: %{code: "UNAUTHORIZED"}}}]
      })
    end

    test "receives an errored update when password changes after subscribing", %{
      socket: socket,
      retro: retro
    } do
      ref = push_doc(socket, @subscription, variables: %{slug: retro.slug, password: "password"})
      assert_reply(ref, :ok, %{subscriptionId: _subscription_id})

      add_item(retro)
      assert_push("subscription:data", %{})

      Retros.update(retro, %{password: "new-password"})

      add_item(retro)

      assert_push("subscription:data", %{
        result: %{
          data: %{"retroUpdated" => nil},
          errors: [%{extensions: %{code: "UNAUTHORIZED"}}]
        }
      })
    end
  end
end
