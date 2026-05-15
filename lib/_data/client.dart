import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';


class Config {
  static String _token = '';
  static final httpLink = HttpLink('https://ptmate-client.hasura.app/v1/graphql', defaultHeaders: {'x-hasura-admin-secret': 'Ib2gLkOdCmhuemuKrYTkoPsCZbZIwn0FKfUmwV1OE0TZtdZt1qvMx440gMqM4aQ7'});
  //static final AuthLink authLink = AuthLink(getToken: () => _token);
  static final AuthLink authLink = AuthLink(getToken: () => 'x-hasura-admin-secret' 'Ib2gLkOdCmhuemuKrYTkoPsCZbZIwn0FKfUmwV1OE0TZtdZt1qvMx440gMqM4aQ7');
  static final WebSocketLink websocketLink = WebSocketLink('wss://ptmate-client.hasura.app/v1/graphql', config: SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
      initialPayload: () async { //initPayload
        return {
          'headers': {'x-hasura-admin-secret': 'Ib2gLkOdCmhuemuKrYTkoPsCZbZIwn0FKfUmwV1OE0TZtdZt1qvMx440gMqM4aQ7'},
        };
      },
    ),
  );
  static final Link link = authLink.concat(httpLink).concat(websocketLink);
}