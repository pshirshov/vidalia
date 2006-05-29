/****************************************************************
 *  Vidalia is distributed under the following license:
 *
 *  Copyright (C) 2006,  Matt Edman, Justin Hipple
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, 
 *  Boston, MA  02110-1301, USA.
 ****************************************************************/

/** 
 * \file tormapwidget.h
 * \version $Id$
 */

#ifndef _TORMAPWIDGET_H
#define _TORMAPWIDGET_H

#include <control/circuit.h>

#include "zimageview.h"


class TorMapWidget : public ZImageView
{
public:
  /** Default constructor. */
  TorMapWidget(QWidget *parent = 0);

  /** Plots the given router on the map using the given coordinates. */
  void addRouter(QString name, float latitude, float longitude);
  /** Plots the given circuit on the map. */
  void addCircuit(Circuit circuit);

public slots:
  /** Selects and hightlights a router on the map. */
  void selectRouter(QString name);
  /** Selects and highlights a circuit on the map. */
  void selectCircuit(Circuit circuit);

signals:
  /** Emitted when the user selects a router on the map. */
  void routerSelected(QString name);
  /** Emitted when the user selects a circuit on the map. */
  void circuitSelected(Circuit circuit);
};

#endif

