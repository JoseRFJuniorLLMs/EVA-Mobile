class Idoso {
  final int id;
  final String nome;
  final DateTime? dataNascimento;
  final String? telefone;
  final String? cpf;
  final String? deviceToken;
  final bool ativo;
  final String nivelCognitivo;
  final bool limitacoesAuditivas;
  final bool usaAparelhoAuditivo;
  final String tomVoz;
  final String preferenciaHorario;

  Idoso({
    required this.id,
    required this.nome,
    this.dataNascimento,
    this.telefone,
    this.cpf,
    this.deviceToken,
    required this.ativo,
    this.nivelCognitivo = 'Normal',
    this.limitacoesAuditivas = false,
    this.usaAparelhoAuditivo = false,
    this.tomVoz = 'Normal',
    this.preferenciaHorario = 'Qualquer horário',
  });

  factory Idoso.fromJson(Map<String, dynamic> json) {
    return Idoso(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nome: json['nome'] ?? '',
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.tryParse(json['data_nascimento'].toString())
          : null,
      telefone: json['telefone'],
      cpf: json['cpf'],
      deviceToken: json['device_token'],
      ativo: json['ativo'] ?? true,
      nivelCognitivo: json['nivel_cognitivo'] ?? 'Normal',
      limitacoesAuditivas: json['limitacoes_auditivas'] ?? false,
      usaAparelhoAuditivo: json['usa_aparelho_auditivo'] ?? false,
      tomVoz: json['tom_voz'] ?? 'Normal',
      preferenciaHorario: json['preferencia_horario'] ?? 'Qualquer horário',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'data_nascimento': dataNascimento?.toIso8601String(),
      'telefone': telefone,
      'cpf': cpf,
      'device_token': deviceToken,
      'ativo': ativo,
      'nivel_cognitivo': nivelCognitivo,
      'limitacoes_auditivas': limitacoesAuditivas,
      'usa_aparelho_auditivo': usaAparelhoAuditivo,
      'tom_voz': tomVoz,
      'preferencia_horario': preferenciaHorario,
    };
  }

  int get idade {
    if (dataNascimento == null) return 0;
    final now = DateTime.now();
    int age = now.year - dataNascimento!.year;
    if (now.month < dataNascimento!.month ||
        (now.month == dataNascimento!.month && now.day < dataNascimento!.day)) {
      age--;
    }
    return age;
  }
}
