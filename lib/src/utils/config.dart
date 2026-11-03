/// Reúne funções utilitárias compartilhadas por diferentes partes do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';

// Cores principais
const mainColor = Color.fromARGB(255, 36, 36, 43);
const whiteColor = Colors.white;
const azulSereno = Color(0xFF0EA5E9);
const brancoNeve = Color.fromARGB(255, 255, 255, 255); // #FFFFFF
const begeClaro = Color(0xFFF7F9FC);

// Cores secundárias
const verdeEsperanca = Color(0xFF22C55E);
const douradoSuave = Color(0xFFF5B93F);
const rosaSuave = Color(0xFFFF6B6B);

// Cores para texto
const cinzaEscuro = Color.fromARGB(255, 51, 51, 51); // #333333
const cinzaClaro = Color.fromARGB(255, 136, 136, 136); // #888888

// Cores adicionais
List<double> sizeBtnOptions = [100, 50];
List<double> sizeBtnInitial = [150, 100];

const amberColor = Color(0xFFF5B93F);
const indigoColor = Color(0xFF7C6BFF);
const tealColor = Color(0xFF00BFA6);
const redColor = Color(0xFFFF6B6B);
const purpleColor = Color(0xFF7C6BFF);
const lightPurpleColor = Color(0xFFAB9FFF);

const deepOrangeColor = Color(0xFFF5B93F);

// Listas de Cores para os Gradientes dos Ícones
const List<Color> gradienteBiblia = [amberColor, Color(0xFFFFD98A)];
const List<Color> gradienteHarpa = [indigoColor, tealColor];
const List<Color> gradienteDevocional = [tealColor, indigoColor];
const List<Color> gradientePalavraDoDia = [deepOrangeColor, redColor];
const List<Color> gradienteAudios = [tealColor, azulSereno];
const List<Color> gradienteApoio = [indigoColor, redColor];
const List<Color> gradienteOutros = [indigoColor, azulSereno];
