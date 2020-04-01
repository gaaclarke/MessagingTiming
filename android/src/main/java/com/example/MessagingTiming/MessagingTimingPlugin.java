package com.example.MessagingTiming;

import android.util.Log;
import androidx.annotation.NonNull;
import java.nio.ByteBuffer;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryCodec;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;

/** MessagingTimingPlugin */
public class MessagingTimingPlugin implements FlutterPlugin, MethodCallHandler {
  private static final String TAG = "MessagingTimingPlugin";
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private BasicMessageChannel<Object> basicMessageChannel;
  private BasicMessageChannel<ByteBuffer> basicMessageChannelBinary;

  @Override
  public void
  onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    setup(flutterPluginBinding.getFlutterEngine().getDartExecutor());
  }

  public static void registerWith(Registrar registrar) {
    MessagingTimingPlugin plugin = new MessagingTimingPlugin();
    plugin.setup(registrar.messenger());
  }

  private void setup(BinaryMessenger binaryMessenger) {
    channel = new MethodChannel(binaryMessenger, "MessagingTiming");
    channel.setMethodCallHandler(this);
    basicMessageChannelBinary = new BasicMessageChannel<ByteBuffer>(
        binaryMessenger, "BasicMessageChannelBinary", BinaryCodec.INSTANCE);
    basicMessageChannelBinary.setMessageHandler(
      new BasicMessageChannel.MessageHandler<ByteBuffer>() {
        public void onMessage(ByteBuffer message,
                              BasicMessageChannel.Reply<ByteBuffer> reply) {
          // TODO: Check message.
          try {
            ByteBuffer buffer =
                ByteBuffer.wrap(android.os.Build.VERSION.RELEASE.getBytes("UTF-8"));
            reply.reply(buffer);
          } catch (Exception ex) {
            reply.reply(null);
          }
        }
      });
    basicMessageChannel = new BasicMessageChannel<Object>(
      binaryMessenger, "BasicMessageChannel", new StandardMessageCodec());
    basicMessageChannel.setMessageHandler(
      new BasicMessageChannel.MessageHandler<Object>() {
        public void onMessage(Object message,
                              BasicMessageChannel.Reply<Object> reply) {
          reply.reply("Android " + android.os.Build.VERSION.RELEASE);
        }
      });
    Pigeon.Api.setup(binaryMessenger, new MyApi());
    try {
      Log.v(TAG, "load library");
      System.loadLibrary("libnative_add.so");
      setupJni();
    } catch (Exception ex) {
      Log.v(TAG, ex.toString());
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private class MyApi implements Pigeon.Api {
    public Pigeon.StringMessage getPlatformVersion(Pigeon.VoidMessage arg) {
      Pigeon.StringMessage result = new Pigeon.StringMessage();
      result.setMessage("Android " + android.os.Build.VERSION.RELEASE);
      return result;
    }
  }

  private native void setupJni();
}
