defmodule Discuss.User do
  use Discuss.Web, :model

  schema "users" do
    field :first_name , :string
    field :last_name , :string
    field :provider , :string
    field :token , :string
    field :email, :string
    has_many :topics, Discuss.Topic
    has_many :comments, Discuss.Comment
    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :provider, :token]) # Include first and last names later
    |> validate_required([:email, :provider, :token])
  end

end
