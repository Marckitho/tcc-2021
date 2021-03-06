function passTurn() {
	if (global.turn == "p") {
		objCull.moves = 1;
		
		with all {
			if (depth == layer_get_depth(layer_get_id("Enemies"))) {
				moves = 1;
			}
		}
		global.turn = "e";
	} else if (global.turn == "e") {
		with all {
			if (depth == layer_get_depth(layer_get_id("Terrain"))) {
				if (object_index == objSpike
				or object_index == objLaser
				or object_index == objTeleporter
				or object_index == objCheckpoint
				or object_index == objGoal) {
					moves = 1;
				}
			}
		}
		global.turn = "o";
	} else if (global.turn == "o") {
		global.turn = "p";
		objPlayer.moves = 1;
		
		// Tiles de Perigo
		with (all) {
			// Inimigos
			if (depth == layer_get_depth(layer_get_id("Enemies"))) {
				// X
				//if (abs(abs(getPosTile(objPlayer)[0]) - abs(getPosTile(self)[0])) == 2) {
				//	instance_create_layer(objPlayer.x + (16 * sign(self.x - objPlayer.x)), objPlayer.y, "Particles", objWarningTile);
				//}
				
				// Y
				//if (abs(abs(getPosTile(objPlayer)[1]) - abs(getPosTile(self)[1])) == 2) {
				//	instance_create_layer(objPlayer.x, objPlayer.y  + (16 * sign(self.y - objPlayer.y)), "Particles", objWarningTile);
				//}
				
				if (object_index == objSlime) {
					if (charged) {
						instance_create_layer(self.x + 16, self.y, "Particles", objWarningTile);
						instance_create_layer(self.x - 16, self.y, "Particles", objWarningTile);
						instance_create_layer(self.x, self.y + 16, "Particles", objWarningTile);
						instance_create_layer(self.x, self.y - 16, "Particles", objWarningTile);
					}
				} else {
					instance_create_layer(self.x + 16, self.y, "Particles", objWarningTile);
					instance_create_layer(self.x - 16, self.y, "Particles", objWarningTile);
					instance_create_layer(self.x, self.y + 16, "Particles", objWarningTile);
					instance_create_layer(self.x, self.y - 16, "Particles", objWarningTile);
				}
				
			}
		}
		
		warningDelay = 90;
		warningCountdown = warningDelay + 15;
	}
}

function passLevel() {
	objPlayer.facing = 3;
	global.level++;
	global.checkpoint = -1;
	
	global.status = "c";
}

function listEnemies() {
	var _depth = layer_get_depth(layer_get_id("Enemies"));
	var _enemies = [];
	
	with all {
		if (depth == _depth) _enemies[array_length(_enemies)] = [x div 16, y div 16];
	}
	
	return _enemies;
}

function listEnemiesNext() {
	var _depth = layer_get_depth(layer_get_id("Enemies"));
	var _enemies = [];
	
	with all {
		if (depth == _depth) _enemies[array_length(_enemies)] = [targetX div 16, targetY div 16];
	}
	
	return _enemies;
}

function listTerrains() {
	var _depth = layer_get_depth(layer_get_id("Terrain"));
	var _terrains = [];
	
	with all {
		if (depth == _depth) _terrains[array_length(_terrains)] = [x div 16, y div 16, object_index];
	}
	
	return _terrains;
}

function enemiesDone() {
	var _depth = layer_get_depth(layer_get_id("Enemies"));
	var _done = true;
	
	with all {
		if (depth == _depth) {
			if (moves > 0) _done = false;
			if (targetX != x or targetY != y) _done = false;
		};
	}
	
	return _done;
}

function terrainsDone() {
	var _depth = layer_get_depth(layer_get_id("Terrain"));
	var _done = true;
	
	with all {
		if (depth == _depth) {
			if (moves > 0) _done = false;
		};
	}
	
	return _done;
}

function tileAt(_tx, _ty) {
	return global.collisionField[_tx][_ty];
}

function getPosTile(_target) {
	return [_target.x div 16, _target.y div 16];
}

function summonRange(_s, _d, _target) {
	if ((getPosTile(_target)[0] >= _s[0]
	and getPosTile(_target)[0] <= _d[0])
	and (getPosTile(_target)[1] >= _s[1]
	and getPosTile(_target)[1] <= _d[1])) {
		return true;
	} else return false;
}

function killEntity(_target) {
	script_execute(_target.kill);
}

function writeTextShaky(_text, _x, _y) {
	var _len = string_length(_text);
	var _wid = 0;
	
	for(var i = 1; i <= _len; i++) {
		draw_text(_x + _wid + random_range(0.4, -0.4), _y + random_range(0.4, -0.4), string_char_at(_text, i));
		_wid += string_width(string_char_at(_text, i));
	}
}

function writeTextVertWave(_text, _x, _y) {
	var _len = string_length(_text);
	var _wid = 0;
	
	for(var i = 1; i <= _len; i++) {
		draw_text(_x + _wid, _y + sin((timer/10) + i), string_char_at(_text, i));
		_wid += string_width(string_char_at(_text, i));
	}
}

function writeTextFullWave(_text, _x, _y) {
	var _len = string_length(_text);
	var _wid = 0;
	
	for(var i = 1; i <= _len; i++) {
		draw_text(_x + _wid + cos((timer/10) + i), _y + sin((timer/10) + i), string_char_at(_text, i));
		_wid += string_width(string_char_at(_text, i));
	}
}

function checkCutscene() {
	var _list = [objLevelTitle, objLevelRestart, objGetSword, objSplashScreen];
	var _cutscene = false;
	
	for (var i = 0; i < array_length(_list); i++) {
		with (_list[i]) {
			if (active) _cutscene = true;
		}
	}
	
	return _cutscene;
}

function cullRange(_entity) {
	if (_entity.x < objCull.startx
		or _entity.x > objCull.endx
		or _entity.y < objCull.starty
		or _entity.y > objCull.endy) {
			return true;
		} else return false;
}