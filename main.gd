extends Control

@export var snake_scene : PackedScene

var score : int
var game_started : bool = false

var cells : int = 20
var cell_size : int = 50

var food_pos : Vector2 
var regen_food : bool = true

var old_data : Array
var snake_data : Array
var snake : Array
var total_coins: int = 0
var restart = false
var snake_theme: StyleBoxFlat = preload("res://snakesegment.tres")

@export var start_speed: float = 0.25
var next_direction := Vector2.RIGHT
var speed := start_speed
var die_wall = true
var die_circle = true
var coin_mult = 1



var start_pos = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction : Vector2
var can_move: bool

var snake_skins_unlocked = [true, false, false, false, false, false]
var snake_skins_cost = [0, 10, 25, 50, 75, 100]
var snake_skins_colors = [
	Color(0.314, 0.722, 0.31, 1.0), 
	Color(0.227, 0.671, 0.702, 1.0),
	Color(0.847, 0.341, 0.31, 1.0),
	Color(0.592, 0.482, 0.792, 1.0),
	Color("1668c1"),
	Color(0.902, 0.6, 0.224, 1.0)]



func _ready():
	new_game()
	set_process(true)
	
func new_game():
	get_tree().paused = false
	if restart: get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()
	score = 0
	$Hud.get_node("Score_Label").text = "SCORE: " + str(score)
	move_direction = up
	can_move = true
	generate_snake()
	move_food()
	print("this is running")
	
func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	
	for i in range(3):
		add_segment(start_pos + Vector2(0, i))
		
func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	SnakeSegment.add_theme_stylebox_override("panel",snake_theme)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)
	SnakeSegment.add_to_group("segments")


func _process(_delta: float):
	move_snake()
		
		
func move_snake():
	if can_move:
		
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction = down
			can_move = false
			if not game_started:
				start_game()
		
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction = up
			can_move = false
			if not game_started:
				start_game()
		
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction = left
			can_move = false
			if not game_started:
				start_game()
		
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction = right
			can_move = false
			if not game_started:
				start_game()
		
func start_game():
	game_started = true
	$MoveTimer.start()
	

func _on_move_timer_timeout() -> void:
	can_move = true
	
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		
		if i > 0:
			snake_data[i] = old_data[i-1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()
	
	
func check_out_of_bounds():
	if (snake_data[0].x < 0 or snake_data[0].x > cells - 1 or snake_data[0].y < 0 or snake_data[0].y > cells - 1) and die_wall:
		end_game()
		
func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i] and die_circle:
			end_game()
			
func check_food_eaten():
	if snake_data[0] == food_pos:
		score += 1
		total_coins += coin_mult
		$Hud.get_node("Score_Label").text = "SCORE: " + str(score)
		$Hud.get_node("coins").text = "COINS: " + str(total_coins)
		add_segment(old_data[-1])
		move_food()
			
func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * cell_size)+ Vector2(25, cell_size + 25)
	regen_food = true
		
		
			
func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true
# Replace with function body.


func _on_game_over_menu_restart() -> void:
	restart = true
	new_game()
	

var books = ["
zxjkbsswhp;
sjbpbhsabhsp

s
sp;s;sllsm mmmcmc cccvcccccffffdfdfddfffgtgvbtgvb yhbn yhnb ujhn ujmnijkmikm, iok,m0po;l.[p;][\
swqqllllllllmkmkmkmk
mkmkmkmkmmk
mkmkmkmkmmkmkmkmkmkmkmmkmkmk
mkmkmkmmkmkmkmkmkmkmkmkmkmknjnjnnjnjbhbbhbgvgvgvgawawawawawaaaaawaaaarrrtgrfsdddssdsdsdsqdwdwwwdwdwdwttgtgtggggtgkkkkikikikikikikiooopoponininommomo
llllllllllmmkkkkkkkkkkkkkkjjjiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuyyyyyyyyyyyyyyyytttttttttttttttttttttttttttttttttttttttttteeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwqqq
deddddddddddddddddddddddddddddddnljnnyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyu





NOTIFICATION_ACCESSIBILITY_INVALIDATE



kokko
koko
o
okk
o




instance_from_id(
	
	huuhuhhuhuhuhu
	
	jiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
	
	9898988888899uipuihovgo  8ses9888ess54
	
	rxfcfhhyf574455555dtifc 
	h8iuygyygyguyugygyy5443333344444459999999
	
	ytyygyggyyggygyrrdrrddrseesesesawwawaqqq33333w3w3w4w4e4e4e4e55r5r  niihihhhg77tt66thijpkkph8fdrsesesrtfnjkmkjbvcrxeses4dtfuhijoooijhftrdsewsedrftgyhujikolokijuhygtfdr  jbftdftbjn bftrdftgyhujkkojihgyftrdseerftgyhujklokijuhygtfdsedfghjkllkojhgfdressdftghujikol;[plokijuhygtfrddftgyhujiklokijuygttresdrftgyhujkduvb  b b b b b      gy g yg yg g gy gg y gygy  gyg y gyg  g gg yg y gy gyg y gyg g  gg g g  g g g g  g yg  gg  gg g g      mk k kk
	 kkkmk
	knkk
	
	kkknik
	kknknk
	knknknkn
	nk
	
	nkknknknknkn
	knknkknkknjjbbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhbhhbhbhbhbhbhbhhgftftfftftftftftftftffttftftftffttfdrdeeddedeseesseseseeseswwaawwawawwawawawawawawawaawwasdxfcvghbjnkmnnjbhbhbhbhhb
	
	ininiiii", "
	
	sigee the world of imagination and wonder. int a little wigglae was 
	" + "between the castle walls lived people and farmmarket sellin gfrwsh produc and beard. they sell livestock as weel. but once came a child of the king of this city and this child when growing up was very arragont and spolied anything that he wanted happened. he first wanted the biggest room int the castle. then to the extreme when 8 of wanting the whole village to eat pie for lunch for a week. however that was food only he could affrod making the whole city in dept by sellin gtheir cattle, clothes, or even their personal air lomes of jewlerary. but this child no one could tell him anything even his own father. he feared if he told the boy anything he would kill him, however the father didnt need anything to do or say. the next couple of years and now he was 12, the brat learnt in his homeschool that his father controls the wealth of the goldmine of the city, this sparked an idea in the child. he concluded that if he becomes king and use the gold to not give upon the city to trade and have a good econmy to use all 100% for himself he could have triple the food, clothes space and so much more. so he went and planned with one of the younger guards that if he poisens the king at night he will recive 25% of his wealth. so they planned it for 2 weeks and the day came. 
	" + "janaury 10th the snow was covering the whole village. everyone is inside realaxing. reviving from the workless hours they put thorugh the spring ,summer and fall. everyone was eating soup and other stored snacks. then when the royal family of the king his son and mother, the king finisheing his drink,                 dropped dead to the floor. the guards rushed in the scene all seing his beat and find nothing the medic trys his best but nothing. the mother drops in tears. then the head guard called grinomo says. he was poisned which means probaly the food crew have done so and their is only 10 possible people. the two main chefs brewer the chef asistents or the jerry bringing the food. but the child toke no time screaming the who it was immetitly. 'it was the jerry he must have done it he wanted to steal the gold from the king as he is the poorest img in the city' Img is an immagrent from a diffrent city but is extremly poor. he came to have a better life. all the sub gaurds hold the poor guard. hes screeming for help (	TRAITORRRRR TRAITOR I WILL LEAVE THE CITTY AND MURDER YOU AND YOUR FAMILY ) the child responds with fake crying ssaying words that will make the city feel bad. then the next day the ruornation for him to become king before goronamo says the whole city and says Unforuntly do the accatnation    of the greatest king of this centory. now for the new dreams of socitey the now son has token the htron
	" + "pump pump pump. the city isnt as happy as the prevoius thron as they acutlly loved the king but now a 12 yearold tha loves only himself. then  when he was crowned it in the assemplby he bcome king. now only two days thenew king did new rules everyone hated. firstly said in a not very fun speech saying multiple things. firstly saying he change the tax of wealth from 10% to 35% more then a third saying that its a Ruturn on investment. unforuntatly he was one of the only who could learn or at least learn. the only other people were the head guard and his teacher making no one understand his big words. secoun dly he will be cutting on expenses like public toilteries and maintence for the vilage and roads to budget to build more space for his castle. then lastly saying people cannot sell fish with garlic since he hated the smell last week. funny enough this was the main dish that brought families together wehn disagreeing. when friends hated each other, or when spouses and brides fought. All these new laws including many others were now way stricter with guards checking everyday the homes of everyw=one the poor and middle class. what the new king didnt only harm the city but also disconnected it from itself. 
	#a couple years past and the new king whose name was John changed it to John de Lion. he was now 19 years and the city became even worse. the city became a prime example of class seperation of only the gaurds the king becoming first class and the rest all farmers peastents traders smithes carpenters and others poor. but the king wanted to explore to other villages he needed a summer home his home bcame to small for him even with 20 revonations and expansions though 7 years. so he rallied his troops or his guards of wants left of the city as most left. he sent a letter to the near city of bridge telling them he will invade to get more land. but hthis village was 3x as big and hade a 10x larger army then theirs and the lives of people accuttly mattered. but since all of his right hands were either exacuted or imprisioned or the best of the other options to be kicked out. he had no one to tell him no. but what he didnt know is that the brigde city wasa renamed by a very familer person named with a J
	#Jerry once a 15 yearold no one 7 years ago now became the king of bridge city and from his amazing impact the city renamed to jerry city. what he did in the 7 years was quick and smart. he worked for a black smith learning all the skills then became a gaurd by firstly making swords and armour for the militry. then rose the ranks and became head gaurd and was right hand of the king.  the king very fond of the young man for his intelect his manners and his respect to everyone engaged his only daughter to him and retired. making him and his new wife king and qween. shortly after hearing that his old city of Mines was asking for war he thought it was time to teach that brat whos boss. he also was needed the goldf to improve somethings for thec ity of bridge. so after asking the athortires and getting their aprroval he  told the city his plan of war. he told the city of mines that he will invade on the week. now a part of johns ego died scared that he mightto be killed telling orders for a sercet dungeon under his room with food and water to last until the invasion ended so his troops instead of training for the week were mining a  hole in his mansion but before even  mining 3% with a over worked scehdule the troops of Jerry village arrived they were all strong rested and full of enegry while the opposing army was to little and underprepared. 
	#the battle lasted as long as the time to blink all the tropps ran back inside their village walls running and screaming. not only were johns troops hungr tired and weak they were also extremly scraed anything could scrae them. they were man with minds of chickens. so the troops came in not harming a single soul from the village. but jerry had his mind on one person john. he rushed in knowing every right and left turn but the place the castle alone was the biggest he has seen he thought to himself nowounder even the middle class were dirty and on the streets. we went bursting in the kings room finding him curled up in the corner. the noble knight stoped and stered his steer and told him you are coming with me johny that was the only time in  12 years someone called him that it was his father when trying to g to discipline him. he startded to cry but this time he wasnt faking. tears going down his face. two other guards came and rap the mans hands to a piece of rope tight. he  then toke only the mean king as a prisioner of war. he then told the city they were safe from john
	#all of the city of mines wanted them to lose to get a new leader. so then jerry agreeded and after trowing john into cell to be totred until he dies. he sent his second head to govern the new city and make reasonable laws and t to use the castle for the people and only have a offece for the govener. the people really did enjoy their new ruller after a decade evrything improved the poulation increase by 3x everyone had a home and food on the table ven 80% of children had education for 5 years of math and liture even the econmy became better by selling the gold for a good price to other traders not for really expensie this made the demand way higher. even the bridge city improved by expanding and even some int people travelling to the mine village like doctors and carpaters to help build the city even when they were not from it and dint benefit. 
	" + "
	how ever at the end of the day the whole village learnt that only caring about your self is never an option. 

		this is story for siege",
	#
	#
#
	#
	"sseseseesesesesesesesesesesesesesesesseesesesesseseesxceddedeeedeededededeeewwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwake up taha dont be a bum 
	i need all the support body ok 
	first legs dont get tired 
	arms hang in their literlly 
	hands keep on going with the pain soon you will feel the best laptop for years to come
	eyes i know you cant blink as much but this is for a beter life 
	brain dont sleep we understand you are tired but dont and bum dont turn arround to sleep and 
	shoulders hold your postion we undrtand you have been standing all day but we need this 
	and heart understand the things i can do with the framework 12 not only can i study better i can cad for my knowlegde and help the school way faster. 
	" + "
	
	jingle bells jingle bells jingle all the way life is so tiring its so depairing jingle bells jingles bells every single note.
	bir bir pata oim tralello tralella bombardillo crocadillo rilli rillario la orcanlalio orcala 
	67 67 67 67 67 67 676 76 7676767676767676
	six seven six seven six seven 
	67 67 67 67676767676 676767 76767667676767 676767676676767676767676676776767676767676767767676 6767676767676767676776766
	lebron james lebron james
	lebron james
	christano ronaldo SUIIIIIIIIIIIIII
	alllalla lalalaa its the d o double gg snooop dooogg
	eminimem she sells ssea sheels on the sea shore but no one buuys her sea shells so she becomes ahomeless
	
	ima fanum tax u right now crowdie who u think u are huh?
	give me all of your money so no one get hurt
	tung tung tung sahur ta ta ta sahur
	>: ( by palms hurt from the metal of my very old macbook 
	its curving in from the edges aswell only if they ahve filleted it or atleast make it a more conforatble material 
", 
"thats why im coding so i can get the new framework 12 with plastic surface with edges of tpu for shock absorbtion. 
it also has a 3x faster cpu then mine of a 4.5 ghz with 12 cores and mine is 1.1 ghz
it can fusion 360 the best cad of all time and can watch videos or atleasat tabs without hearing like under a plane. 
it will have a better storage since you can a larger one and replace it yourself. 
it will also have A TOUCH SCREEN FOR NOOOOTTTTEEEES!!!!!! i can also draw unlimted suply 
i can also take better note on it
it will also last until i finsih university if they continue to make a really good cpus 
i dont know what to write you see its really hard to crasp a certain topic if you dont know what it is :   D also i hate english its a super dumb poo languge and its all exceptions and how is bufffalo buffualo buffalo buffalo buffalo buffalo buffalo buffalo a gramaticlly correct sentance like it makes no cents like buffalo 
apartly has 3 diffrent meanings the city in new york the animal and to bully of intematde others. 
so it means that a buffalian buffulo bullies buffalian buffalo who bully bufallian buffalo 
my ego is so large it lie all the time i am ashemed of it i dont know how i will be a father in the future when i cant control my self

highschool is going to be peak for me but not the peak of my life but instead the spark to my lifes success 
i will learn many things like
func rock climbing 
	i will master V5 or more hopfully if i have every day traing of a couple of fingertests and some push ups and planks 
func Enginnering
	 i will learn many aspects including the kwonlegde such as hemistry physics and math 
	but two will learn more practical like ftc cad build prototyping and researhc. i will also need to teach other people about my skills and kwolegde especcly the younger generations.
	then thirly i will amply my skills in my coop and cllaborating and getting expericance from the real world. 

func Discipline 
	 i learn to not do want my ego wants like sins and other things that will harm me phyically mentally now and after when i become older. 
	i will learn to do things i need to do like cleaning me my space studie eat and help others and climb 
	
func The book
	i will read the book and become one with it im nothing without it i need it to be mental and safe from harm
	i will need to do a half page of sulam every day 
	it will teach me unconsiuously teach me life the correct way
	not only will it help me now but more importantly soon after i pass as theats the time which really matters
	
func Fincace 
	im so gratful to have food and all my needs met when doing my studies their is thousandths and millitions and maybe billions that would wish to be replaced in my spot they might even do a billion things better then me
	i will need to save for any big purchases such as a laptop(not anymore), univerty tuition and othe big expenses
	i will need to get a winter job and summer job to just make minium of 3 k 
	i will need to work all days for the balck friday from 9-9 each 
	
func studies 
	i will need to get the best of grades by studying everyday for cem and physics even for 10 mins each just for review. now thank god atleast now its easy but later not as much
	i need to get 95 average just to get in waterloo uoft mcmaster for mechanical enginnering.
	i will need to research and memorize each course like under the plam of my hand for mechanical engneering. 
	i will research special education teacher as it might be my split major
	
func extracurricler
	i will try to learn other cad programs if i can get them like autocad and solid works. as these might be industry standerd. also i must learn more blender to use for animations for my designs. 
	i will do the 100 hr program and do more to get a Frame work 12 with a upgraded cpu and some more like a Hdmi sd card holder adn if i can do it  micro sd fancy chips and a stylus (if i dont do the hour ill probally buy it with my money)
	i need to learn how to profect 10 dishes and how to make simlear varoius incause i need food and moms not around.
	i need to make the baby sitting business a thing complete with a logo a anoucment poster of the company a website fincaials and others. . 
	i will learn to drive to the point where i can drive on the highway. my mother allowing me to drive her (i cant drive when she is in the car) and the most of all to drive alone
	
i need to eat im super hungry and thirsty and if i dont finish in the next 45 mins im cooked so please update the timer or tracker 

today i  ate wheels of happinesss and if your wondering why its called that its because it acutlly give you happiness and the a nice feature is that its vegen crunchy and round with soft middle like dounts and chicken nuggets had a child. felt like i was healeed physically and spirtally 
i need a new laptop its extremly laggy its fan is alrealy as loud as a factory with just running godot. 
me and my brother share it and i think thats a major factor why its so slow. 
and since its 5 years old and soon 6 skull wait ITS THAT OLD DAMN UNC no wounder its on life spport on a charging cable Skull three their is now M4 for air but i still have the intel from the 1990 skull whoever at apple should give students free laptops to anyone who needs one like fr 
anyways i saw way to much framework 12 laptop reviews and they are amazing. frome the touch screen amazing to the keyboard nearly perfect not to thin my be clicked by accident or to thick i have to punch a door. the ports OMG they are absolutly amazing with full customization i could have a hdmi port if i have a setup at home Micro sds if i edit alot or use files i could use usbc if i charge and thats my charger ior if i still didnt update my cables with usb A cords

i think hitler should have never been alive

the couch im on isway to be boucny i could replacate air raderiz at home for free. 
did i tell u i love driving i drove yesturday my bros truck and itwas cool with gas pedals instead of my other brothers electric truck i got used to it tho 


sigma sigma sigma boy sigma boy aliliaijuwuniiuiuniuuiiui0oi98uhhhhhhhhhh

i will need to be the best to my family from brothers to nieces and nephews 
i need to take care of the young and listen to the older 
i needed to rpint the new shooter           i should slap self for bad time mangemnt 
even tho i just told a random kid that homework helps build it clearly i odnt have it.



Shows 
func rookie
	i enjoyed this show it showed what happens in a police departent and what the trainings like. i also love the action in it
	
func Vsauce
	this show makes me think idk how but bro brings 50 ideas with the same main idea making me use 110% of my brain
	i swear to god i might have increased my IQ by 10% after watching for some time
	
func veritasuim
	this show explains and shows how diffrent science chemistry physics mathamatics statictis and others with nice histroy and other things
	
func dr house
	this show represents the smartest damn doctor but he is also the biggest jerk in the world. he is able to solve any solution but the people around him hate him
	

func physics
	displacement is distance with direction
	velocity is speed with direction
	speed is stance over time
	accellartion is velocity over time
	
i will not be bad 
i will not be bad
i will not be bad
i will not be bad
i will not be bad
i will not be bad 

i will not procastanate
i will not procastante
i will not procastante 
i will not procastanate

i will not be a bum this year
i will not be a bum this year
i will not be a bum this year


I will be the 1% of people in the world

I will be the 1%  of people in history mankind

i will need to be the best

their is not backing down 
 
its either we go home or home run 

no turning back on right path 

i need to strong bookd smart, have experianc, logical smart, disiplined rich by the end of this year.



i need to help my class to be also the 1% 
we need eachother to study to eat to be close to each other, we need to laugh have fun 
",

"awsqqwwqwwsswswswkokkokokok
kookookkokookkokookkokookokokookokokookokkokokokoo
okookokokkookokokoookkokkookkokookkoko

kookokokokokokko


6767676767676676767676767676767676767676676767
sixseven six seven six  seven six   seven six    seven 
six seveeeeeeeeeeeeeeeeeeen
six seeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeevn
siiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiix seven

aishsajsjsakss
sbjasksab
sabujsjjsab

jisksjaiksiksinksjisijsjisijjisoiosiojsojia
sjisps
siasjipqwijkwsijijjkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo         [ppp]pppllllllllllllllllllllllllllllllllllllllllllllllllllllllll
lllllllllllllll lllllllllllllllllll lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll

i like how my generation is cooked for the next couple of years. all programs have been competative and jobs even more. the ecomny i crashed immagreints is the worst temproy solution (im not hating on the immagreints i understand that everyone who comes, comes for a better life im acutal second generation but my older brothers  ar first )
it dosent help the country for it population cause we need to fix the root of the problem of high costs of living. its kinda of unbearable just to have a livable life each person in the family needs to havea salry of 60 k each on avreage
shusua[
	subhsa]juhsa
	sajuasn
	sn
	subja
	su
	sbus
	asa
	
	abnsb
	jas
	boas
	boj
	bo
	bos
	bo
	as
	b
	nbn
	jn
	nn
	
	iii
	ji
	iipipjip
	ii
	ijijijjipji
	jijij
	ip
	p
	jpijipjipjip
	pjiijpijpipjijp
	
	jiji
	ij
	i
	j
	m
	kkknkn
	km
	km
	mk
	mkmk
	
	mk
	mk
]




hack club thank you so much for the program it really will help me from learning how to code the infuntracure of code the community and most imporntaly a laptop. i cant express how much im gratful for this oppuruntiy 
 hopfully this is what gets me into waterloo
ex


asbjusbaksjsjajsb

sbjsjsbj

aianaik
as
jnsjnjsnajas
j
sjjsa
kiasjias
jiis
jis
ji
asi
saisjia
s
i
isij
asijasijasiasi
as
jisjiasjiasjij
isajisaj
pasjp
sko
kosakosak
oasko
kaos
ko
askoas
koasko[sakokoskosak[osako
as
ksokaso

asokosakosokokaskdiuhadhbsgydhbh  sbujs js nsbou js js j js jso ]
s s
nsinnsi
ss
i
s
i
a
a

ai
 



amidk,skmmksskmww 
sskmsjnksojns

sknsn
kkasas
s
nn
ss
ns
ani am ii am i am i am i am i am i am i am i am i am i am i amnininnimo
sai
asinsnsnnosnsnosanonoinotoieino
en
a j j j j j j j j j j j j j j  j j j j j j j j  j j j jjj j j jjj jjj j jj j j j j j jjj  j j j  j j  j jj j j j 
nas

sin i wish i could eat breakfast ngl it would hit real hard man.

nisinsin
ainnininsinisnsins snisninsisnisisn
aniainasinsain
sainsa
i
i love pancakea s jsa]nasn
as
kasnojsakmas
asjnasn
a
asnipasnipnaisi
as
asniaisniasnjp
asnipasnias
npas
nnipasn
pasnisaji-asjinasjniji-asi-hdjdksiisjjcisjisajiasjisjaiisjisjsijcisjisjiscjisjcsijsijscijcsijcsijcs
iscsijcjis
nnkp
  "
]

var books_unlocked = [false, false, false, false, false]

var book_unlocked_prices = [5, 20, 67, 100, 500]

var book_titles = ["Spam", "Siege", "BrainRot", "Tahas Yapp", "RageQuit"]

func _on_game_over_menu_library() -> void:
	$Library.visible = true
	$GameOverMenu.visible = false
	$Skin_Shop.visible = false 



func unlocked(book_number):
	print("look here")
	if books_unlocked[book_number]:
		view_book(book_number)
	else:
		if total_coins >= book_unlocked_prices[book_number]:
			view_book(book_number)
			total_coins-=book_unlocked_prices[book_number]
			books_unlocked[book_number] = true
		else:
			$Library/container/Message.text= ("you donnt have enough coins")
			
func view_book(book_number):
	$view_book.visible = true
	$view_book/ScrollContainer/VBoxContainer/story.text = books[book_number]
	$view_book/ScrollContainer/VBoxContainer/title.text = book_titles[book_number]
	

func on_closed_shop() -> void:
	$view_book.visible= false
	



func _on_button_pressed_spam() -> void:
	unlocked(0)
	unlocked(0)

func _on_button_pressed_Siege() -> void:
	unlocked(1)

func _on_button_pressed_BrainRot() -> void:
	unlocked(2)


func _on_button_pressed_Tahas_Life() -> void:
	unlocked(3)


func _on_button_pressed_RageQuit() -> void:
	unlocked(4)


func _on_button_pressed_goback() -> void:
	$Library.visible = false
	$Skin_Shop.visible = false 
	$GameOverMenu.visible = true



func _on_go_back_2_button_pressed() -> void:
	$Skin_Shop.visible = false 
	$GameOverMenu.visible = true
	$Library.visible = false

func _on_regular_pressed() -> void:
	switch_snake_skin(0)

func _on_fire_pressed() -> void:
	switch_snake_skin(2)

func _on_ice_pressed() -> void:
	switch_snake_skin(1)

func _on_portal_pressed() -> void:
	switch_snake_skin(3)

func _on_gold_pressed() -> void:
	switch_snake_skin(5)


func _on_game_over_menu_skinshop() -> void:
	$Library.visible = false
	$GameOverMenu.visible = false
	$Skin_Shop.visible = true 


func _on_water_pressed() -> void:
	switch_snake_skin(4)

func switch_snake_skin(skin_number):
	if snake_skins_unlocked[skin_number] or total_coins >= snake_skins_cost[skin_number]:
		if not snake_skins_unlocked[skin_number]:
			total_coins -= snake_skins_cost[skin_number]
			snake_skins_unlocked[skin_number] = true
			$Hud/coins.text = "Coins: " + str(total_coins) 
		snake_theme.bg_color = snake_skins_colors[skin_number]
		$MoveTimer.wait_time = 0.1
		coin_mult = 1
		die_circle = true
		die_wall = true
		match skin_number:
			1:
				$MoveTimer.wait_time = 0.13
			2:
				$MoveTimer.wait_time = 0.07
			3:
				die_wall = false
			4:
				die_circle = false
			5:
				coin_mult = 2
