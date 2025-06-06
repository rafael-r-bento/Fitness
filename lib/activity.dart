/*
 * FitnessAMP - a fitness app with 3 pre-defined exercises
 * Copyright (C) 2023-2024  Rafael Bento
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

class Activity {
  final String date;
  int ab;
  int mountainClimber;
  int biceps;

  Activity(
      {this.date = "", this.ab = 0, this.mountainClimber = 0, this.biceps = 0});

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'ab': ab,
      'mountainClimber': mountainClimber,
      'biceps': biceps,
    };
  }
}
