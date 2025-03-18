import 'dart:io';
import 'dart:math';

// 캐릭터 클래스 정의
class Character {
  String name;
  int health;
  late int attackPower;
  int defense;

  Character(this.name, this.health, this.attackPower, this.defense);

  // 몬스터 공격 메서드
  void attackMonster(Monster monster) {
    int damage = max(0, attackPower - monster.defense);
    monster.health -= damage;
    print('$name이(가) ${monster.name}에게 $damage의 데미지를 입혔습니다!');
  }

  // 방어 메서드
  void defend(int damage) {
    health += damage; // 방어 시 받을 뻔한 데미지만큼 체력 회복
    print('$name이(가) 방어하여 $damage만큼 체력을 회복했습니다!');
  }

  // 상태 출력 메서드
  void showStatus() {
    print('[$name] 상태 - 체력: $health, 공격력: $attackPower, 방어력: $defense');
  }
}

// 몬스터 클래스 정의
class Monster {
  String name;
  int health;
  int maxAttackPower;
  late int attackPower;
  int defense = 0; // 몬스터 방어력은 0으로 고정

  Monster(this.name, this.health, this.maxAttackPower) {
    // 몬스터의 공격력은 최대값 범위 내에서 랜덤하게 설정
    final random = Random();
    attackPower = random.nextInt(maxAttackPower) + 1;
  }

  // 캐릭터 공격 메서드
  int attackCharacter(Character character) {
    int damage = max(0, attackPower - character.defense);
    character.health -= damage;
    print('${this.name}이(가) ${character.name}에게 $damage의 데미지를 입혔습니다!');
    return damage; // 입힌 데미지 반환 (방어 시 이 값만큼 회복)
  }

  // 상태 출력 메서드
  void showStatus() {
    print('[$name] 상태 - 체력: $health, 공격력: $attackPower');
  }
}

// 게임 클래스 정의
class Game {
  Character? character;
  List<Monster> monsters = [];
  int defeatedMonsterCount = 0;
  int targetMonsterCount = 0;

  // 게임 초기화 메서드
  void initialize() {
    loadCharacterStats();
    loadMonsterStats();

    // 목표 몬스터 수 설정 (최대 몬스터 리스트 크기)
    targetMonsterCount = monsters.length;

    print('\n게임 초기화 완료!\n');
    print('목표: $targetMonsterCount마리의 몬스터를 물리치세요!\n');
  }

  // 캐릭터 스탯 불러오기
  void loadCharacterStats() {
    try {
      final file = File('characters.txt');
      final contents = file.readAsStringSync();
      final stats = contents.split(',');

      if (stats.length != 3) throw FormatException('Invalid character data');

      int health = int.parse(stats[0]);
      int attack = int.parse(stats[1]);
      int defense = int.parse(stats[2]);

      String name = getCharacterName();
      character = Character(name, health, attack, defense);
      print('캐릭터 $name이(가) 생성되었습니다!');
    } catch (e) {
      print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
      print('기본 캐릭터를 생성합니다.');
      String name = getCharacterName();
      character = Character(name, 50, 10, 5); // 기본값 설정
    }
  }

  // 몬스터 스탯 불러오기
  void loadMonsterStats() {
    try {
      final file = File('monsters.txt');
      final contents = file.readAsStringSync();
      final lines = contents.split('\n');

      for (String line in lines) {
        if (line.trim().isEmpty) continue;

        final stats = line.split(',');
        if (stats.length != 3)
          throw FormatException('Invalid monster data: $line');

        String name = stats[0].trim();
        int health = int.parse(stats[1].trim());
        int maxAttackPower = int.parse(stats[2].trim());

        monsters.add(Monster(name, health, maxAttackPower));
      }

      print('몬스터 ${monsters.length}마리가 로드되었습니다!');
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      print('기본 몬스터를 생성합니다.');
      monsters = [
        Monster('Batman', 30, 20),
        Monster('Spiderman', 20, 30),
        Monster('Superman', 30, 10),
      ]; // 기본 몬스터 생성
    }
  }

  // 사용자로부터 캐릭터 이름 입력받기
  String getCharacterName() {
    String? name;
    final validName = RegExp(r'^[a-zA-Z가-힣]+$');

    do {
      stdout.write('캐릭터의 이름을 입력하세요 (한글, 영문만 가능): ');
      name = stdin.readLineSync()?.trim();

      if (name == null || name.isEmpty) {
        print('이름을 입력해주세요!');
      } else if (!validName.hasMatch(name)) {
        print('이름은 한글과 영문만 포함할 수 있습니다.');
        name = null;
      }
    } while (name == null);

    return name;
  }

  // 랜덤 몬스터 가져오기
  Monster getRandomMonster() {
    if (monsters.isEmpty) {
      throw Exception('더 이상 몬스터가 없습니다!');
    }

    final random = Random();
    int index = random.nextInt(monsters.length);
    return monsters[index];
  }

  // 전투 메서드
  bool battle() {
    if (character == null || monsters.isEmpty) {
      print('게임 초기화가 필요합니다!');
      return false;
    }

    try {
      Monster monster = getRandomMonster();
      print('\n${monster.name}과(와) 전투를 시작합니다!');

      while (monster.health > 0 && character!.health > 0) {
        // 상태 출력
        character!.showStatus();
        monster.showStatus();

        // 사용자 행동 선택
        stdout.write('\n행동을 선택하세요: 공격하기(1), 방어하기(2): ');
        String? action = stdin.readLineSync()?.trim();

        if (action == '1') {
          // 공격
          character!.attackMonster(monster);
        } else if (action == '2') {
          // 방어 (몬스터의 공격을 미리 계산)
          int potentialDamage = max(
            0,
            monster.attackPower - character!.defense,
          );
          character!.defend(potentialDamage);

          // 몬스터는 공격하지 않음 (이미 방어에서 계산됨)
          continue;
        } else {
          print('잘못된 입력입니다. 다시 선택하세요.');
          continue;
        }

        // 몬스터가 죽었는지 확인
        if (monster.health <= 0) {
          print('${monster.name}을(를) 물리쳤습니다!');
          defeatedMonsterCount++;
          monsters.remove(monster); // 몬스터 리스트에서 제거
          return true;
        }

        // 몬스터 공격
        monster.attackCharacter(character!);

        // 캐릭터가 죽었는지 확인
        if (character!.health <= 0) {
          print('${character!.name}이(가) 쓰러졌습니다. 게임 오버!');
          return false;
        }

        print('\n--- 턴 종료 ---\n');
      }

      return true;
    } catch (e) {
      print('전투 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  // 게임 시작 메서드
  void startGame() {
    initialize();

    bool continueGame = true;
    bool victory = false;

    while (continueGame && character!.health > 0 && monsters.isNotEmpty) {
      bool battleResult = battle();

      if (!battleResult) {
        continueGame = false;
        continue;
      }

      // 이긴 경우: 목표 달성 여부 확인
      if (defeatedMonsterCount >= targetMonsterCount) {
        print('\n축하합니다! 모든 몬스터를 물리쳤습니다!');
        victory = true;
        break;
      }

      // 다음 전투 여부 확인
      if (monsters.isNotEmpty) {
        stdout.write('\n다음 몬스터와 대결하시겠습니까? (y/n): ');
        String? answer = stdin.readLineSync()?.toLowerCase();

        if (answer != 'y') {
          print('게임을 종료합니다.');
          continueGame = false;
        }
      }
    }

    // 게임 결과 저장
    saveGameResult(victory);
  }

  // 게임 결과 저장 메서드
  void saveGameResult(bool victory) {
    stdout.write('\n결과를 저장하시겠습니까? (y/n): ');
    String? answer = stdin.readLineSync()?.toLowerCase();

    if (answer == 'y') {
      try {
        final file = File('result.txt');
        final result = victory ? '승리' : '패배';
        final content =
            '캐릭터 이름: ${character!.name}, 남은 체력: ${character!.health}, 게임 결과: $result';

        file.writeAsStringSync(content);
        print('결과가 저장되었습니다!');
      } catch (e) {
        print('결과 저장 중 오류가 발생했습니다: $e');
      }
    } else {
      print('결과를 저장하지 않습니다.');
    }
  }
}

void main() {
  print('========== RPG 게임 시작 ==========\n');

  Game game = Game();
  game.startGame();

  print('\n========== 게임 종료 ==========');
}
