defmodule Discuss.TopicController do
  use Discuss.Web, :controller
  alias Discuss.Topic
  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render conn, "index.html", topics: topics
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{}) 
    render conn, "new.html", changeset: changeset
  end

  def show(conn, %{"id" => topic_id}) do
    topic = Repo.get!(Topic, topic_id) # use get! to throw error to user if topic isn't found in database
    render conn, "show.html", topic: topic
  end 

  def create(conn, %{"topic" => topic}) do
    changeset = 
      conn.assigns.user
      |> build_assoc(:topics)
      |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _topic} -> 
        conn
        |> put_flash(:info, "Topic Created")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)

    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do # topic = new params from form
    changeset = 
      Topic 
      |> Repo.get(topic_id) # Create existing topic from db
      |> Topic.changeset(topic) # Use existing and new params to create changeset

    case Repo.update(changeset) do # Update existing topic in db based on changeset
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: topic
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    # get! and delete! methods returns an error code to user if so no case statement is needed later to handle errors 
    Repo.get!(Topic, topic_id) |> Repo.delete!

    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  defp check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn

    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You can't edit that.")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end

end