defmodule TelegramBot.API do
  use HTTPoison.Base

  @post_headers %{"Content-type" => "application/x-www-form-urlencoded"}
  @photos  ["tuvok", "tpol3", "tpol1", "tpol2", "spock1", "spock2", "spock3", "spock4", "spock5", "spock6", "tuvok3", "tuvok2", "vulcan1"]
  @captions  ["Infinite diversity in infinite combination.", "My mind to your mind... my thoughts to your thoughts...", "In accepting the inevitable, one finds peace.", "Tick tok, Tuvok", "Human math.. I'm crying!", "Insufficient facts always invite danger.", "Once you have eliminated the impossible, whatever remains, however improbable, must be the truth.", "Live long and prosper.", "Not every species is cut out for logic.", "Curious.", "Interesting.", "There's a difference between keeping an open mind and believing something because you want it to be true.", "You're obviously unable to have a physical relationship without developing an emotional attachment.", "It is clear that living among humans has caused my reasoning to become compromised.", "Optimism doesn't alter the laws of physics."]

  def process_url(url) do
    "https://api.telegram.org/bot" <> token <> "/" <> url
  end

  defp token, do: Application.get_env(:telegram_bot, :bot_token)

  def get_updates(offset \\ nil, limit \\ 100, timeout \\ 30) do
    {:ok, response} = post("getUpdates", {:form, [offset: offset, limit: limit, timeout: timeout]}, @post_headers)
    %{"ok" => true, "result" => result} = response.body
    TelegramBot.Models.Updates.new(result)
  end

  def send_message(chat_id, text) do
    post("sendMessage", {:form, [chat_id: chat_id, text: text]}, @post_headers)
  end

  def send_sticker(chat_id, sticker) do
    post("sendSticker", {:form, [chat_id: chat_id, sticker: sticker]}, @post_headers)
  end

  def send_photo(chat_id, filename \\ "fake", caption \\ nil) do 
    filename = "img/"<>sample_list(@photos)<>".jpg"
    unless caption do
      caption = sample_list(@captions)
    end
    post("sendPhoto", {:multipart, [{"chat_id", Integer.to_string(chat_id)}, {"caption", caption}, {:file, filename,{"form-data", [{"filename", filename},{"name", "photo"}]}, [{"Content-Type", "image/jpeg"}] }]})
  end

  def process_response_body(body) do
    body |> Poison.decode!
  end

  def sample_list(photos) do
    Enum.shuffle(photos) |> List.first
  end
end
