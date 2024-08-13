defmodule Xrt.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Xrt.Repo

  @spec retro_factory() :: Xrt.Retros.Retro.t()
  def retro_factory do
    %Xrt.Retros.Retro{
      slug: sequence(:slug, &"test_slug-#{&1}")
    }
  end

  @spec retro_item_factory() :: Xrt.Retros.RetroItem.t()
  def retro_item_factory do
    %Xrt.Retros.RetroItem{
      title: "Sample title",
      type: :works,
      user_uuid: "user-uuid",
      retro: build(:retro),
      ref: sequence(:ref, &"#{&1}")
    }
  end

  @spec action_item_factory() :: Xrt.Retros.ActionItem.t()
  def action_item_factory do
    %Xrt.Retros.ActionItem{
      title: "Sample title",
      completed: false,
      retro: build(:retro)
    }
  end

  @spec retro_item_vote_factory() :: Xrt.Retros.RetroItemVote.t()
  def retro_item_vote_factory do
    %Xrt.Retros.RetroItemVote{
      retro_item: build(:retro_item),
      user_uuid: sequence(:user_uuid, &"user_uuid-#{&1}")
    }
  end
end
