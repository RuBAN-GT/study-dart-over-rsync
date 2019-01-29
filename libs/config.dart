class Config {
  String host;
  int port;
  String user;
  List<String> exclude = [];
  List<Scheme> schemes = [];

  Config(Map config) {
    this.host = config['host'];
    this.port = config['port'];
    this.user = config['user'];
    this.exclude = config['exclude'];
    this.schemes = config['schemes'].map((Map item) {
      return new Scheme(item['source'], item['destination']);
    });
  }

  List<String> basicOptions() {
    final List<String> options = [
      '-auz',
      '--progress',
      '--delete',
      '-e',
      'ssh -p ${this.port}'
    ];

    this.exclude.forEach((item) {
      options.add('--exclude');
      options.add(item);
    });

    return options;
  }

  List<List<String>> schemeOptions([download = false]) {
    return this.schemes.map((item) {
      List<String> options = this.basicOptions();

      options.addAll(
        item.options(
          host: this.host, 
          user: this.user, 
          download: download
        )
      );

      return options;
    });
  }
}

class Scheme {
  String source;
  String destination;

  Scheme(this.source, this.destination);

  List<String> options({
    String host = '', 
    String user = '',
    bool download = false
  }) {
    String source = download ? this.destination : this.source;
    String destination = download ? this.source : this.destination;

    if (host != '') {
      if (download) {
        source = '$user@$host:$source';
      } else {
        destination = '$user@$host:$destination';
      }
    }

    return [source, destination];
  }
}
