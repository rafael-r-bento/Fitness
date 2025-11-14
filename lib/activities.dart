/*
 * Fitness - a fitness app
 * Copyright (C) 2023-2025  Rafael Bento
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

class Activities {
  final String date;
  int remadaArticuladaSupinada;
  int puxadaArticulada;
  int supinoVertical;
  int crucifixo;
  int desenvolvimento;
  int biceps;
  int elevacaoLateral;
  int abdominalSupraSolo;
  int esteira1;
  int cadeiraFlexora;
  int cadeiraExtensora;
  int legHorizontal;
  int cadeiraAbdutora;
  int panturrilhaSentado;
  int leg45;
  int esteira2;

  Activities(
      {this.date = "",
      this.remadaArticuladaSupinada = 0,
      this.puxadaArticulada = 0,
      this.supinoVertical = 0,
      this.crucifixo = 0,
      this.desenvolvimento = 0,
      this.biceps = 0,
      this.elevacaoLateral = 0,
      this.abdominalSupraSolo = 0,
      this.esteira1 = 0,
      this.cadeiraFlexora = 0,
      this.cadeiraExtensora = 0,
      this.legHorizontal = 0,
      this.cadeiraAbdutora = 0,
      this.panturrilhaSentado = 0,
      this.leg45 = 0,
      this.esteira2 = 0});

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'remadaArticuladaSupinada': remadaArticuladaSupinada,
      'puxadaArticulada': puxadaArticulada,
      'supinoVertical': supinoVertical,
      'crucifixo': crucifixo,
      'desenvolvimento': desenvolvimento,
      'biceps': biceps,
      'elevacaoLateral': elevacaoLateral,
      'abdominalSupraSolo': abdominalSupraSolo,
      'esteira1': esteira1,
      'cadeiraFlexora': cadeiraFlexora,
      'cadeiraExtensora': cadeiraExtensora,
      'legHorizontal': legHorizontal,
      'cadeiraAbdutora': cadeiraAbdutora,
      'panturrilhaSentado': panturrilhaSentado,
      'leg45': leg45,
      'esteira2': esteira2
    };
  }
}
