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
  int biceps;
  int elevacaoLateral;
  int abdominalSupraSolo;
  int flexao;
  int escalador;

  Activities(
      {this.date = "",
      this.biceps = 0,
      this.elevacaoLateral = 0,
      this.abdominalSupraSolo = 0,
      this.flexao = 0,
      this.escalador = 0});

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'biceps': biceps,
      'elevacaoLateral': elevacaoLateral,
      'abdominalSupraSolo': abdominalSupraSolo,
      'flexao': flexao,
      'escalador': escalador
    };
  }
}
