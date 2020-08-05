# Doomtrain 末日火车

A factorio mod based game, players need to learn how to live on a long way, struggling with food, water, coldness, hotness and biters attacks.

## 游戏内容

星球上的人类，由于过度的工业和自动化导致了整个星球的严重污染，空气，饮水，土壤。气候被破坏，变化无常。
现在只存活下来的人类已经不多，在某个部族区域有这么一群人，他们靠在火车上发展。。。故事内容需要构思，先到此。。。

## 游戏特质

1. 由于户外土壤被严重破坏，几乎无法栽培任何农作物，所以只能在火车上进行无土栽培
2. 水也遭到了严重的污染，所以饮水问题也严重，需要通过抽取坏外水源至火车，然后进行进化处理才能饮用
3. 原有的自然动物已经濒临灭绝，为数不多的情况可以在户外捕到一些鱼类，其他就剩下由于污染变异的大群怪物，只要有污染产生的地方，它们就会嗅觉到人类的所在


## 基本的游戏逻辑

1. 人类需要食物和水，才能继续存活下去，在这个基础上，发展已经遗失的先祖科技，建造大型的运输飞船，希望通过逃离这个星球，在外太空寻找适合人类居住和生活的绿色星球
2. 起初，这个部族拥有一节火车，
    * 在里面可以进行种植获取素食食品，
    * 水需要在有水资源的附近抽取到火车上净化后才能饮用
    * 能培养的家禽和牲畜品种有限，鸡，猪等等，鱼虽然可以养殖，但需要许多的水和空间
3. 运气好，可以在户外找到废弃的火车和车厢，有时候可用，但有时候需要进行维修
4. 变异生物到处流窜，随时可能遭到袭击
5. 户外地表矿物很稀少，所以不断的往新的区域探索才能维持稳定的资源需求

## 可行性问题
    
    由于factorio的开放api，有一定的局限性，许多预期的特性需要进行一个基本的逻辑预估

1. 饮食，饮水factorio本身没有这些功能，唯一的鱼只是用于治疗生命值。 如果实现这些，需要考虑饥渴度问题。
    基本构思，通过on_tick事件实现定时器功能，目前还不清楚是否存在内置定时器或者多线程调用
2. ...

## TODO List

> Train Module Class

1. When players enter the train from one carriage, should be teleported nearby the door of the carriage
2. When players exit out the carriage from one door, should be teleported to the surface which the carriage stays on and nearby this carriage
3. When new train created(disconnected or connected another train), the building layout in carriages maybe disordered. Needs a solution for this.
4. When the carriages destroyed, players in these carriages should be repositioned to proper places.
5. Carriages can be mined or not , can be built or not, the behavior should be configurable.
6. Different types of carriage creation.
7. The performance about train creation and destruction refactoring.