function aiRandom() {
	var _x = x div 16; // Tile x atual
	var _y = y div 16; // Tile y atual
	var _targetx = undefined; // Tile x alvo
	var _targety = undefined; // Tile y alvo
	var _dir = undefined; // Direção (Hor ou Ver)
	
	do {
		_dir = choose(0, 1);
		if (_dir == 0) { // Horizontal
			_targetx = _x + choose(-1, 1);
			_targety = _y;
		} else { // Vertical
			_targety = _y + choose(-1, 1);
			_targetx = _x;
		}
	} until(tilemap_get(global.tilemap, _targetx, _targety) == 1 or tilemap_get(global.tilemap, _targetx, _targety) == 2) 
	
	objPlayer.x = _targetx * 16;
	objPlayer.y = _targety * 16;
}

function aiBlindSearch() {
	var _x = x div 16; // Tile x atual
	var _y = y div 16; // Tile y atual
	var _targetx = undefined; // Tile x alvo
	var _targety = undefined; // Tile y alvo
	
	for(var i = 0; i < tilemap_get_height(global.tilemap); i++) {
		for(var j = 0; j < tilemap_get_width(global.tilemap); j++) {
			if (tilemap_get(global.tilemap, i, j) == 2) {
				_targetx = j;
				_targety = i;
			}
		}
	}
	
	
	if (_targetx - _x != 0 and (tilemap_get(global.tilemap, _x + sign(_targetx - _x), _y) == 1
	or tilemap_get(global.tilemap, _x + sign(_targetx - _x), _y) == 2)) {
		objPlayer.x += 16 * sign(_targetx - _x);
	} else if (_targety - _y != 0 and (tilemap_get(global.tilemap, _x, _y + sign(_targety - _y)) == 1
	or tilemap_get(global.tilemap, _x, _y + sign(_targety - _y)) == 2)) {
		objPlayer.y += 16 * sign(_targety - _y);
	}
	
}

function aiAStar() {

if (instance_exists(objPlayer)) {
	// Inicializa os arrays de nós abertos e fechados
	var _openQueue = [];
	var _closedQueue = [];
	
	// Inicializa o pathing
	var _path = [];
	var _neighbors = [];
	
	// Pega as coordenadas iniciais e finais
	var _start = [x div 16, y div 16];
	var _dest = [objPlayer.x div 16, objPlayer.y div 16];
	
	// Adiciona o nó inicial ao array aberto
	// 1. Inicialize Q com o nó de busca (S) como única entrada;
	_openQueue = addNode(_openQueue, _start[0], _start[1], _start[0], _start[1], _start, _dest);
	//show_message(_openQueue);
	
	// 2.1 Se Q está vazio, interrompa.
	while (array_length(_openQueue) > 0) {
		// 2.2  Se não, escolha o melhor elemento de Q;
		_openQueue = sortNodes(_openQueue);
		//show_message(_openQueue);
		
		// 3. Se o estado (n) é um objetivo, retorne n;
		//show_message(string(_openQueue[0][0]) +" == " +string(_dest))
		if (_openQueue[0][0][0] == _dest[0] and _openQueue[0][0][1] == _dest[1]) {
			//show_message("CHEGOU");
			var _p = _openQueue[0];
			//show_message(_p);
			//show_message(_closedQueue);
			//show_message(indexOfNode(_closedQueue, [3, 1]));
			while (_p[2] != 0) {
				//show_message(_p[2])
				_path[array_length(_path)] = _p[0];
				//show_message(_path);
				_p = _closedQueue[indexOfNode(_closedQueue, _p[1])];
			}
			break;
		}
		
		// 5. Encontre os descendentes do estado (n) que não estão em visitados e crie todas as extensões de n para cada descendente;
		_neighbors = getNeighbors(_openQueue[0][0]);
	
		for (var i = 0; i < array_length(_neighbors); i++) {
			if (indexOfNode(_closedQueue, _neighbors[i]) == -1
			and indexOfNode(_openQueue, _neighbors[i]) == -1) {
				// 6. Adicione os caminhos estendidos a Q e vá ao passo 2;
				_openQueue = addNode(_openQueue, _neighbors[i][0], _neighbors[i][1], _openQueue[0][0][0], _openQueue[0][0][1], _start, _dest);
			}
		}
	
		// 4. (De outro modo) Remova n de Q;
		array_insert(_closedQueue, array_length(_closedQueue), _openQueue[0]);
		array_delete(_openQueue, 0, 1);
		
		
	}
	
	// show_message(array_length(_openQueue));
	
	//show_message(_openQueue);
	
	//_neighbors = getNeighbors(_openQueue[0][0]);
	
	//for (var i = 0; i < array_length(_neighbors); i++) {
	//	if (indexOfNode(_closedQueue, _neighbors[i]) == -1
	//	and indexOfNode(_openQueue, _neighbors[i]) == -1) {
	//		_openQueue = addNode(_openQueue, _neighbors[i][0], _neighbors[i][1], _openQueue[0][0][0], _openQueue[0][0][1], _start, _dest);
	//	}
	//}
	
	//array_insert(_closedQueue, array_length(_closedQueue), _openQueue[0]);
	//array_delete(_openQueue, 0, 1);
	
	//_openQueue = sortNodes(_openQueue);
	
	// finarmente... da o proximo passo
	//show_message(_path);
	
	if (array_length(_path) > 0) {
		var _nextStep = _path[array_length(_path) - 1];
		
		// Verificar Inimigos
        //for (var j = 0; j < array_length(listEnemies()); j++) {
        //    if (listEnemiesNext()[j][0] == _nextStep[0] and listEnemiesNext()[j][1] == _nextStep[1]) {
        //        _nextStep = _start;
        //    }
        //}
		
		// Matar player
		if (_nextStep[0] == getPosTile(objPlayer)[0]
			and _nextStep[1] == getPosTile(objPlayer)[1]) {
			objPlayerDeath.highlightEntity = self;
			killEntity(objPlayer);
		} else {
			if (_nextStep[0] != _start[0]) {
				targetX += 16 * sign(_nextStep[0] - _start[0]);
			} else if (_nextStep[1] != _start[1]) {
				targetY += 16 * sign(_nextStep[1] - _start[1]);
			}
		}
	} else {
		//show_message("Sem caminho...")
	}
}
}