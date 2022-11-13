part of models;

class ApplicationContext {
  final Map<String, dynamic> _currentContext;
  final Map<String, dynamic> _receivedContext;

  ApplicationContext(this._currentContext, this._receivedContext);

  ///A Map<String, dynamic> represents the current application context on this respective application.
  Map<String, dynamic> get currentData => _currentContext;

  ///A Map<String, dynamic> represents the received application context on this respective application.
  Map<String, dynamic> get receivedData => _receivedContext;

  factory ApplicationContext.fromJson(Map<String, dynamic> json) =>
      ApplicationContext(
        fromRawMapToMapStringKeys(json['current'] as Map),
        fromRawMapToMapStringKeys(json['received'] as Map),
      );
}
