require 'mumble-ruby'

_channel = 'Arc'
_username = 'Clotho'
_server = 'jukejuice.com'
_port = 64738
_owner = 'Sundancer'
_init_message = 'Hey Contessa!'

def log(msg)
  msg = Time.now.inspect + ' - ' + msg

  puts msg
  open('mumble-log', 'a') do |f|
    f.puts msg
  end
end

def handle_message(cli, msg)
  sender = cli.users[msg.actor]
  message = msg.message

  if msg.tree_id.nil?
    return
  end
  
  log '---TREE---'
  
  unless sender.nil?
    log 'Sender: ' + sender.name
  end
  
  msg.tree_id.each do |chan|
    log 'Treed from: ' + cli.channels[chan].name
  end
  
  unless message.nil?
    log 'Message: ' + message;
  end
end

def handle_user_removal(cli, rmv)
  user = cli.users[rmv.session]
  mod = cli.users[rmv.actor]
  reason = rmv.reason
  is_ban = rmv.ban

  unless user.nil? or mod.nil?
    log rmv.ban ? '---BAN---' : '---KICK---'
    log (rmv.ban ? 'Banned user: ' : 'Kicked user: ') + user.name
    log 'Mumble mod: ' + mod.name
    unless reason.nil?
      log 'Reason: ' + reason
    end
  end
end

client = Mumble::Client.new(_server, _port, _username);

client.on_connected do
  client.me.mute
  client.me.deafen
  client.join_channel(_channel)
  client.text_user(_owner, _init_message)
end

client.on_text_message do |msg|
  handle_message(client, msg)
end

client.on_user_remove do |rmv|
  handle_user_removal(client, rmv)
end

client.connect
gets; # wait for user to supply a newline before terminating
client.disconnect;