import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import "dart:io";

import "package:nyxx_lavalink/nyxx_lavalink.dart";

final singleCommand = SlashCommandBuilder(
    "help", "This is example help command", [])
  ..registerHandler((event) async {
    // All "magic" happens via ComponentMessageBuilder class that extends MessageBuilder
    // from main nyxx package. This new builder allows to create message with components.
    final componentMessageBuilder = ComponentMessageBuilder();
    // Start by setting the content, this is the text that shows at the top of the message.
    componentMessageBuilder.content = "Try some of the components below!";

    // There are two types of button - regular ones that can be responded to an interaction
    // and url button that only redirects to specified url.
    // Here we are focusing on regular button that we can respond to.
    // Label is what user will see on button, customId is id that we ca use later to
    // catch button event and respond to, and style is what kind of button we want create.
    //
    // Adding selects is as easy as adding buttons. Use MultiselectBuilder with custom id
    // and list of multiselect options.
    final firstRow = ComponentRowBuilder()
      ..addComponent(ButtonBuilder(
          "This is button label", "thisisid", ComponentStyle.success))
      ..addComponent(ButtonBuilder(
          "This is another button label", "thisisid2", ComponentStyle.success));
    final secondRow = ComponentRowBuilder()
      ..addComponent(MultiselectBuilder("customId", [
        MultiselectOptionBuilder("example option 1", "option1"),
        MultiselectOptionBuilder("example option 2", "option2"),
        MultiselectOptionBuilder("example option 3", "option3"),
      ]));

    // Then component row can be added to message builder and sent to user.
    componentMessageBuilder
      ..addComponentRow(firstRow)
      ..addComponentRow(secondRow);
    await event.respond(componentMessageBuilder);
  });

// To handle button interaction you need need function that accepts
// ButtonInteractionEvent as parameter. Since button event is interaction like
// slash command it needs to acknowledged and/or responded.
// If you know that command handler would take more that 3 second to complete
// you would need to acknowledge and then respond later with proper result.
Future<void> buttonHandler(IButtonInteractionEvent event) async {
  await event
      .acknowledge(); // ack the interaction so we can send response later

  // Send followup to button click with id of button
  await event.sendFollowup(MessageBuilder.content(
      "Button pressed with id: ${event.interaction.customId}"));
}

// Handling multiselect events is no different from handling button.
// Only thing that changes is type of function argument -- it now passes information
// about values selected with multiselect
Future<void> multiselectHandlerHandler(
    IMultiselectInteractionEvent event) async {
  await event
      .acknowledge(); // ack the interaction so we can send response later

  // Send followup to button click with id of button
  await event.sendFollowup(MessageBuilder.content(
      "Option chosen with values: ${event.interaction.values}"));
}

void main() async {
  final bot = NyxxFactory.createNyxxWebsocket(
      "OTMxNzI0MzIwMzY2MDM0OTk0.YeIl5A.7UuffpRQ0klGvj7-IZWKWqCSFRA",
      GatewayIntents.allUnprivileged)
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(
        CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(
        IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  bot.eventsWs.onReady.listen((IReadyEvent e) {
    print("Ready!");
  });

  final cluster = ICluster.createCluster(bot, Snowflake("931724320366034994"));

  // This is a really simple example, so we'll define the guild and
  // the channel where the bot will play music on
  final guildId = Snowflake("449043857351507968");
  final channelId = Snowflake("861252819821920258");

  // Add your lava link nodes. Empty constructor assumes default settings to lavalink.
  await cluster.addNode(NodeOptions());

  await for (final msg in bot.eventsWs.onMessageReceived) {
    if (msg.message.content == "!join") {
      final channel = await bot.fetchChannel<IVoiceGuildChannel>(channelId);

      // Create lava link node for guild
      cluster.getOrCreatePlayerNode(guildId);

      // Connect to channel
      channel.connect();
    } else if (msg.message.content == "!queue") {
      // Fetch node for guild
      final node = cluster.getOrCreatePlayerNode(guildId);

      // get player for guild
      final player = node.players[guildId];

      print(player!.queue);
    } else if (msg.message.content == "!skip") {
      final node = cluster.getOrCreatePlayerNode(guildId);

      // skip the current track, if it's the last on the queue, the
      // player will stop automatically
      node.skip(guildId);
    } else if (msg.message.content == "!nodes") {
      print("${cluster.connectedNodes.length} available nodes");
    } else if (msg.message.content == "!update") {
      final node = cluster.getOrCreatePlayerNode(guildId);

      node.updateOptions(NodeOptions());
    } else {
      // Any other message will be processed as potential title to play lava link
      final node = cluster.getOrCreatePlayerNode(guildId);

      // search for given query using lava link
      final searchResults = await node.searchTracks(msg.message.content);

      // add found song to queue and play
      node.play(guildId, searchResults.tracks[0]).queue();
    }
  }

//  COMANDOS QUANDO COLOCA "/" NO CHAT
  IInteractions.create(WebsocketInteractionBackend(bot))
    ..registerSlashCommand(
        singleCommand) // Register created before slash command
    ..registerButtonHandler("thisisid",
        buttonHandler) // register handler for button with id: thisisid
    ..registerMultiselectHandler("customId",
        multiselectHandlerHandler) // register handler for multiselect with id: customId
    ..syncOnReady(); // This is needed if you want to sync commands on bot startup.

  // late IMessage message;
  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen((IMessageReceivedEvent e) async {
    void respondeMensagem() async {
      if (e.message.content == 'bruno gay') {
        final replyBuilder = ReplyBuilder.fromMessage(e.message);
        final messageBuilder = MessageBuilder.content("Gay é tu")
          ..replyBuilder = replyBuilder;
        await e.message.channel.sendMessage(messageBuilder);
      }
    }

    void respondeMensagemComImagem() async {
      if (e.message.content == "kennedy gay") {
        // Files argument needs to be list of AttachmentBuilder object with
        // path to file that you want to send. You can also use other
        // AttachmentBuilder constructors to send File object or raw bytes
        final replyBuilder = ReplyBuilder.fromMessage(e.message);
        final messageBuilder = MessageBuilder.content("Gay é tu")
          ..files = [AttachmentBuilder.path("assets/teste.jpg")]
          ..replyBuilder = replyBuilder;
        await e.message.channel.sendMessage(messageBuilder);
        // message = await e.message.channel.sendMessage(MessageBuilder()
        //   ..files = [AttachmentBuilder.path("assets/teste.jpg")]);
      }
    }

    print('${e.message.author.username} mandou: ${e.message.content}');
    respondeMensagem();
    respondeMensagemComImagem();
  });
}
