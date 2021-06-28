curl http://localhost/battles/3/ -H 'X-Token: 77bbc1dc-26d4-446b-abcd-5aa616474fec'
{ 
  "name": "Batalla de Famousagin",
  "replay": {"url": "http://localhost:8080/battles/3/faucet", "via": "GET"},
  "ghost": {
    in: "01.01.2010,80,....",
    sensors: [1, 3, 5, 7]
  },
  "alarms": [
    {"type":"Nave enemiga acercandose", "when": "2001-01-01T01:47:03", "sensor": 8},
    {"type":"Sensor descompuesto",      "when": "2001-01-01T01:12:14", "sensor": 9},
    {"type":"Sensor descompuesto",      "when": "2001-01-01T01:52:23", "sensor": 5},
    {"type":"Nave enemiga acercandose", "when": "2001-01-01T01:02:37", "sensor": 1},
  ],
  "data": [
     "01.01.2010,80,....",
     "01.01.2010,80",
     "01.01.2010,80",
     "01.01.2010,80",
     "01.01.2010,90",
     "01.01.2010,90",
     "01.01.2010,90",
     "01.01.2010,81",
     "01.01.2010,82"]
}

cual es la probabilidad de que una nave este escoltando la nave fantasma mado que su medicion el superior a tal y que esta en un cluster

P(Escolta | EnCluster & MedidaInferior & ) = 99%


