defmodule Xrt.RetrosTest do
  use Xrt.DataCase
  use ExUnitProperties

  import StreamData
  import Xrt.Factory

  alias Xrt.Retros

  alias Xrt.Retros.{
    ActionItem,
    Retro,
    RetroItem
  }

  describe "create/1" do
    test "creates with status :initial by default" do
      assert {:ok, %Retro{status: :initial}} = Retros.create("test_slug")
    end

    property "creates with slug length between 8 and 32" do
      check all(slug <- string(:alphanumeric, min_length: 8, max_length: 64)) do
        assert {:ok, %Retro{slug: slug}} = Retros.create(slug)
      end
    end

    property "does not create with slug length smaller than 8" do
      check all(slug <- string(:alphanumeric, min_length: 0, max_length: 7)) do
        assert {:error, _} = Retros.create(slug)
      end
    end

    property "does not create with slug length bigger than 32" do
      check all(slug <- string(:alphanumeric, min_length: 65, max_length: 256)) do
        assert {:error, _} = Retros.create(slug)
      end
    end

    test "does not create with nil slug" do
      assert {:error, _} = Retros.create(nil)
    end

    property "creates with password length between 8 and 32" do
      check all(password <- string(:alphanumeric, min_length: 8, max_length: 32)) do
        slug = "slug-#{password}"

        assert {:ok, %Retro{slug: ^slug, password_hash: password_hash}} =
                 Retros.create(slug, password: password)

        assert password_hash != nil
      end
    end

    property "doesn't create with password shorter than 8" do
      check all(password <- string(:alphanumeric, min_length: 0, max_length: 8)) do
        assert {:error, _} = Retros.create("slug", password: password)
      end
    end

    property "doesn't create with password longer than 32" do
      check all(password <- string(:alphanumeric, min_length: 32, max_length: 256)) do
        assert {:error, _} = Retros.create("slug", password: password)
      end
    end
  end

  describe "find_or_create_by_slug/1" do
    @slug "test_slug"

    test "creates with given slug new retro if not existing" do
      assert {:ok, %Retro{id: id, slug: @slug}} = Retros.find_or_create_by_slug(@slug)
      assert id != nil
    end

    test "returns the existing retro if found" do
      %{id: id, slug: slug} = insert(:retro)

      assert {:ok, %Retro{id: ^id, slug: slug}} = Retros.find_or_create_by_slug(slug)
    end

    test "if slug is nil, generates a random one" do
      {:ok, %Retro{slug: slug}} = Retros.find_or_create_by_slug(nil)

      refute is_nil(slug)
    end

    test "creates based on the previous retro" do
      previous = insert(:retro, slug: "test-slug-1")

      assert {:ok, %Retro{slug: "test-slug-2"}} =
               Retros.find_or_create_by_slug(nil, previous_retro_id: previous.id)
    end

    @tag :focus
    test "creates based on the previous retro with password" do
      previous = insert(:retro, slug: "test-slug-1")

      assert {:ok, %Retro{slug: "test-slug-2", password_hash: password_hash}} =
               Retros.find_or_create_by_slug(nil,
                 previous_retro_id: previous.id,
                 password: "password"
               )

      assert password_hash ==
               <<106, 89, 90, 204, 15, 70, 213, 177, 17, 227, 44, 209, 112, 120, 137, 178, 85,
                 114, 129, 221, 102, 198, 94, 170, 94, 14, 21, 188, 40, 173, 8, 25>>
    end
  end

  describe "add_item/2" do
    setup do
      {:ok, %{retro: insert(:retro)}}
    end

    @title "Some test title"
    @item_type :works
    @user_uuid "user-uuid"

    test "adds the item to the retro", %{retro: retro} do
      retro_id = retro.id

      assert {:ok, %RetroItem{title: @title, retro_id: ^retro_id}} =
               Retros.add_item(retro, %{title: @title, type: @item_type, user_uuid: @user_uuid})
    end

    test "with nil title doesn't add the item", %{retro: retro} do
      assert {:error, _} =
               Retros.add_item(retro, %{title: nil, type: @item_type, user_uuid: @user_uuid})
    end

    test "with nil type doesn't add the item", %{retro: retro} do
      assert {:error, _} = Retros.add_item(retro, %{title: nil, type: nil, user_uuid: @user_uuid})
    end

    test "with invalid type doesn't add the item", %{retro: retro} do
      assert {:error, _} =
               Retros.add_item(retro, %{title: @title, type: :invalid_type, user_uuid: @user_uuid})
    end

    test "with nil user_uuid doesn't add the item", %{retro: retro} do
      assert {:error, _} =
               Retros.add_item(retro, %{title: @title, type: @item_type, user_uuid: nil})
    end

    test "with non existing retro doesn't add the item" do
      assert {:error, _} =
               Retros.add_item(%Retro{id: nil}, %{
                 title: @title,
                 type: @item_type,
                 user_uuid: @user_uuid
               })
    end

    test "it increments the reference", %{retro: retro} do
      assert {:ok, %RetroItem{ref: "00"}} =
               Retros.add_item(retro, %{title: @title, type: @item_type, user_uuid: @user_uuid})

      assert {:ok, %RetroItem{ref: "01"}} =
               Retros.add_item(retro, %{title: @title, type: @item_type, user_uuid: @user_uuid})

      assert {:ok, %RetroItem{ref: "02"}} =
               Retros.add_item(retro, %{title: @title, type: @item_type, user_uuid: @user_uuid})
    end

    @title "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus rutrum non nibh sed luctus. Donec sapien nulla, imperdiet non efficitur quis, ornare in dui. Sed sagittis justo ornare magna pharetra sagittis. Etiam scelerisque in ligula ac vestibulum. Vivamus vehicula mauris a bibendum orci aliquam."

    test "with title longer than 256 bytes it adds the item", %{retro: retro} do
      retro_id = retro.id

      assert {:ok, %RetroItem{title: @title, retro_id: ^retro_id}} =
               Retros.add_item(retro, %{title: @title, type: @item_type, user_uuid: @user_uuid})
    end
  end

  describe "add_action_item/2" do
    setup do
      {:ok, %{retro: insert(:retro)}}
    end

    @title "Some test title"

    test "adds the action item to the retro", %{retro: retro} do
      retro_id = retro.id

      assert {:ok, %ActionItem{title: @title, retro_id: ^retro_id}} =
               Retros.add_action_item(retro, %{title: @title})
    end

    test "with nil title doesn't add the action item", %{retro: retro} do
      assert {:error, _} = Retros.add_action_item(retro, %{title: nil})
    end

    test "with non existing retro doesn't add the action item" do
      assert {:error, _} = Retros.add_action_item(%Retro{id: nil}, %{title: @title})
    end

    @title "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus rutrum non nibh sed luctus. Donec sapien nulla, imperdiet non efficitur quis, ornare in dui. Sed sagittis justo ornare magna pharetra sagittis. Etiam scelerisque in ligula ac vestibulum. Vivamus vehicula mauris a bibendum orci aliquam."

    test "with title longer than 256 bytes it adds the action item", %{retro: retro} do
      retro_id = retro.id

      assert {:ok, %ActionItem{title: @title, retro_id: ^retro_id}} =
               Retros.add_action_item(retro, %{title: @title})
    end
  end

  describe "find_retro_items/2" do
    test "gets all items for the given retro and type" do
      retro = insert(:retro)
      %{id: other_retro_item_id} = insert(:retro_item, retro: retro)
      %{id: retro_item_id} = retro_item = insert(:retro_item, retro: retro)

      insert(:retro_item, retro: retro, type: :improve)
      insert(:retro_item, type: :works)
      insert(:retro_item_vote, retro_item: retro_item)

      assert [%RetroItem{id: ^other_retro_item_id}, %RetroItem{id: ^retro_item_id}] =
               Retros.find_retro_items(retro, :works)
    end

    test "when retro is in actions status, sorts the items by votes" do
      retro = insert(:retro, status: :actions)
      medium_voted = insert(:retro_item, retro: retro)
      less_voted = insert(:retro_item, retro: retro)
      most_voted = insert(:retro_item, retro: retro)

      insert(:retro_item_vote, retro_item: less_voted)
      insert(:retro_item_vote, retro_item: medium_voted)
      insert(:retro_item_vote, retro_item: medium_voted)
      insert(:retro_item_vote, retro_item: most_voted)
      insert(:retro_item_vote, retro_item: most_voted)
      insert(:retro_item_vote, retro_item: most_voted)

      expected = [most_voted.id, medium_voted.id, less_voted.id]
      actual = Retros.find_retro_items(retro, :works) |> Enum.map(fn x -> x.id end)

      assert expected == actual
    end
  end

  describe "find_action_items/2" do
    setup do
      retro = insert(:retro)

      action_item = insert(:action_item, retro: retro)

      insert(:action_item)

      {:ok, %{retro: retro, action_item: action_item}}
    end

    test "gets all items for the given retro and type", %{
      action_item: %{id: action_item_id},
      retro: retro
    } do
      assert [%ActionItem{id: ^action_item_id} | []] = Retros.find_action_items(retro)
    end
  end

  describe "add_vote/2" do
    @user_uuid "current-user-uuid"

    test "adds a vote" do
      retro_item = insert(:retro_item)

      assert Retros.vote_count(retro_item) == 0

      {:ok, _} = Retros.add_vote(retro_item, @user_uuid)
      {:ok, _} = Retros.add_vote(retro_item, @user_uuid)

      assert Retros.vote_count(retro_item) == 2
    end
  end

  describe "vote_count/1" do
    test "returns vote count for retro items and subitems for a given retro" do
      retro_item = insert(:retro_item)
      similar_item = insert(:retro_item, parent_retro_item_id: retro_item.id)

      insert(:retro_item_vote, retro_item: retro_item)
      insert(:retro_item_vote, retro_item: similar_item)

      assert Retros.vote_count(retro_item) == 2
    end
  end

  describe "find_similar_items/1" do
    test "returns similar retro items for a retro" do
      retro_item = insert(:retro_item)
      similar_item = insert(:retro_item, parent_retro_item_id: retro_item.id)
      result = Retros.find_similar_items(retro_item) |> Enum.map(fn x -> x.id end)
      expected_result = [similar_item.id]

      assert result == expected_result
    end
  end

  describe "set_parent_id/2" do
    test "sets parent id for a retro item" do
      item = insert(:retro_item)
      parent = insert(:retro_item)

      Retros.set_parent_id(item.id, parent.id)

      actual = Xrt.Repo.get(RetroItem, item.id).parent_retro_item_id
      expected = parent.id

      assert actual == expected
    end
  end

  describe "remove_item/1" do
    test "removes the record for retro item" do
      item = insert(:retro_item)

      actual = Xrt.Repo.get(RetroItem, item.id)

      assert actual.id == item.id

      Retros.remove_item(item.id)

      actual = Xrt.Repo.get(RetroItem, item.id)
      assert actual == nil
    end
  end

  describe "remove_action_item/1" do
    test "removes the record for action item" do
      item = insert(:action_item)

      actual = Xrt.Repo.get(ActionItem, item.id)

      assert actual.id == item.id

      Retros.remove_action_item(item.id)

      actual = Xrt.Repo.get(ActionItem, item.id)
      assert actual == nil
    end
  end

  describe "votes_left_for/2" do
    @user_uuid "test_uuid"

    setup do
      retro = insert(:retro)

      retro_item = insert(:retro_item, retro: retro)

      {:ok, %{retro: retro, retro_item: retro_item}}
    end

    test "returns the remaining votes for the user", %{retro: retro, retro_item: retro_item} do
      assert Retros.votes_left_for(retro, @user_uuid) == 20

      insert(:retro_item_vote, retro_item: retro_item, user_uuid: @user_uuid)

      assert Retros.votes_left_for(retro, @user_uuid) == 19

      other_retro_item = insert(:retro_item, retro: retro)
      insert(:retro_item_vote, retro_item: other_retro_item, user_uuid: @user_uuid)

      assert Retros.votes_left_for(retro, @user_uuid) == 18

      item_for_other_retro = insert(:retro_item)
      insert(:retro_item_vote, retro_item: item_for_other_retro, user_uuid: @user_uuid)

      assert Retros.votes_left_for(retro, @user_uuid) == 18
    end
  end
end
