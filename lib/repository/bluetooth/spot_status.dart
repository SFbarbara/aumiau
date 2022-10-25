enum BleStatusEnum {
  blsDesconectado,
  blsConectando,
  blsConectado,
  blsBuscando,
  blsEncontrado,
  blsNaoEncontrado,
  blsDistante,
  blsFalhou,
  blsConsultando,
  blsTransmitindo,
}

class SpotStatus {
  BleStatusEnum status;
  int progresso;

  SpotStatus(this.status, this.progresso);
}
