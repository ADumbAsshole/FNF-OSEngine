package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;
import flixel.tweens.FlxEase;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var tracksSprite:FlxSprite;
	var background:FlxSprite;
	var newBg:FlxSprite;
	var spikes:FlxSprite;
	var diffBg:FlxSprite;
	var scoreText:FlxText;
	var descText:FlxText;
	var desc:String;

	public var weekName:String;

    var noBgSprite:String = 'menuDesat';

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var intendedColor:FlxColor;
	var newColor:FlxColor;
	var colorTween:FlxTween;
	var bgTween:FlxTween;

	var grpWeekText:FlxTypedGroup<FlxText>;
	var grpWeekList:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var difficultyText:FlxText;
	var leftArrow:FlxText;
	var rightArrow:FlxText;
	var noBg:Bool = true;

	var loadedWeeks:Array<WeekData> = [];
	var colors:Array<WeekData> = [];

	override function create()
	{
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		FlxG.camera.follow(camFollowPos, null, 1);

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		var descText:FlxText = new FlxText(0, 10);
		descText.text = desc;
		descText.setFormat(Paths.font("ANDYB.ttf"), 32);
		descText.scrollFactor.set();
		descText.screenCenter(X);

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("ANDYB.ttf"), 32);
		rankText.scrollFactor.set();
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		grpWeekText = new FlxTypedGroup<FlxText>();
		add(grpWeekText);

		grpWeekList = new FlxTypedGroup<FlxSprite>();
		add(grpWeekList);

		background = new FlxSprite().loadGraphic(Paths.image(noBgSprite));
		background.antialiasing = ClientPrefs.globalAntialiasing;
		background.scrollFactor.set();
		background.scale.set(0.94, 0.94);
		add(background);

		newBg = new FlxSprite().loadGraphic(Paths.image(noBgSprite));
		newBg.antialiasing = ClientPrefs.globalAntialiasing;
		newBg.scrollFactor.set();
		newBg.scale.set(0.94, 0.94);
		newBg.alpha = 0;
		add(newBg);
		noBg = true;

		spikes = new FlxSprite(FlxG.width - 280, -130).loadGraphic(Paths.image('spikes'));
		spikes.angle = -14;
		spikes.antialiasing = ClientPrefs.globalAntialiasing;
		spikes.scrollFactor.set();
		add(spikes);

		var blackThingie:FlxSprite = new FlxSprite(spikes.x + 136, -100).makeGraphic(400, FlxG.height * 2, FlxColor.BLACK);
		blackThingie.angle = spikes.angle;
		blackThingie.antialiasing = ClientPrefs.globalAntialiasing;
		blackThingie.scrollFactor.set();
		add(blackThingie);

		function spikesMotion() {
			var spX = 32;
			var spY = 127;
			spikes.x += spX;
			spikes.y += spY;
			FlxTween.tween(spikes, {x: spikes.x - spX, y: spikes.y - spY}, 0.7, {
				onComplete: function(twn:FlxTween) {
					spikesMotion();
				}
			});
		}
		spikesMotion();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			loadedWeeks.push(weekFile);
			WeekData.setDirectoryFromWeek(weekFile);
		}

		for (i in 0...loadedWeeks.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var weeksListSprite:FlxSprite = new FlxSprite(FlxG.width - 650 + (i * 80), 160 * i + 40).loadGraphic(Paths.image('selectorThing'));
			weeksListSprite.antialiasing = ClientPrefs.globalAntialiasing;
			var weekText:FlxText = new FlxText(0, 0, 0, leWeek.storyName, 36);
			// CHOOSE A BETTER FONT
			weekText.setFormat(Paths.font("ANDYB.ttf"), 70, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
			weekText.borderSize = 2.5;
			weekText.x = weeksListSprite.x + (weeksListSprite.width / 2) - (weekText.width / 2);
			weekText.y = weeksListSprite.y + (weeksListSprite.height / 2) - (weekText.height / 2);
			//trace(leWeek.songs[0][2]);
			weeksListSprite.color = FlxColor.fromRGB(leWeek.songs[0][2][0], leWeek.songs[0][2][1], leWeek.songs[0][2][2]);
			grpWeekList.add(weeksListSprite);
			grpWeekText.add(weekText);
			add(weeksListSprite);
			add(weekText);
		}

		diffBg = new FlxSprite().loadGraphic(Paths.image('diffBg'));
		diffBg.x = FlxG.width - diffBg.width;
		diffBg.y = FlxG.height - diffBg.height;
		diffBg.antialiasing = ClientPrefs.globalAntialiasing;
		diffBg.scrollFactor.set();
		add(diffBg);

		scoreText = new FlxText(0, diffBg.y + diffBg.height - 45, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("Andy Bold", 32);

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		tracksSprite = new FlxSprite(0, diffBg.y + 20).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.x = diffBg.x + diffBg.width - tracksSprite.width - 60;
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		tracksSprite.scrollFactor.set();
		add(tracksSprite);

		txtTracklist = new FlxText(0, tracksSprite.y + 60, 0, '');
		txtTracklist.setFormat(Paths.font("ANDYB.ttf"), 32, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		txtTracklist.borderSize = 2.4;
		txtTracklist.scrollFactor.set();
		add(txtTracklist);
		add(scoreText);

		difficultyText = new FlxText();
		// CHOOSE A BETTER FONT
		difficultyText.setFormat(Paths.font("ANDYB.ttf"), 70, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		difficultyText.borderSize = 2.4;
		difficultyText.scrollFactor.set();
		difficultySelectors.add(difficultyText);

		leftArrow = new FlxText(0, 0, 0, '<');
		leftArrow.setFormat(Paths.font(''), 40, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		leftArrow.font = difficultyText.font;
		leftArrow.scrollFactor.set();
		difficultySelectors.add(leftArrow);

		rightArrow = new FlxText(0, 0, 0, '>');
		rightArrow.setFormat(Paths.font(''), 40, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		rightArrow.font = difficultyText.font;
		rightArrow.scrollFactor.set();
		difficultySelectors.add(rightArrow);

		add(descText);

		changeWeek();
		changeDifficulty();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('Andy Bold', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		scoreText.text = "WEEK SCORE:" + lerpScore;
		scoreText.x = difficultyText.x + (difficultyText.width / 2) - (scoreText.width / 2);
		scoreText.scrollFactor.set();

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			if (upP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (downP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if(newColor != intendedColor) {
				if(colorTween != null) {
					colorTween.cancel();
				}
				if(bgTween != null) {
					bgTween.cancel();
				}
				intendedColor = newColor;
				colorTween = FlxTween.color(diffBg, 0.2, diffBg.color, intendedColor, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
				});
				newBg.alpha = 0;
				if (!noBg) {
					bgTween = FlxTween.tween(newBg, {alpha: 1}, 0.2, {
						onComplete: function(twn:FlxTween) {
							bgTween = null;
							newBg.alpha = 0;
							background.loadGraphic(newBg.graphic);
						}
					});
				} else background.loadGraphic(Paths.image(noBgSprite));
			}

			if (noBg) background.color = diffBg.color;
			else background.color = FlxColor.WHITE;
			tracksSprite.color = diffBg.color;
			txtTracklist.borderColor = diffBg.color;
			diffBg.color = diffBg.color;

			if (controls.UI_RIGHT)
				rightArrow.borderSize = 3.4;
			else
				rightArrow.borderSize = 1.5;

			if (controls.UI_LEFT)
				leftArrow.borderSize = 3.4;
			else
				leftArrow.borderSize = 1.5;

			leftArrow.x = difficultyText.x - leftArrow.width - 6;
			leftArrow.y = difficultyText.y + (difficultyText.height / 2) - (rightArrow.height / 2);

			rightArrow.x = difficultyText.x + difficultyText.width + 6;
			rightArrow.y = difficultyText.y + (difficultyText.height / 2) - (rightArrow.height / 2);

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);
			else if (upP || downP)
				changeDifficulty();

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			if(colorTween != null) {
				colorTween.cancel();
			}
			if(bgTween != null) {
				bgTween.cancel();
			}
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (stopspamming == false)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.camera.flash(FlxColor.WHITE, 1);

			//grpWeekText.members[curWeek].startFlashing();

			stopspamming = true;
		}

		// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
		var songArray:Array<String> = [];
		var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
		for (i in 0...leWeek.length) {
			songArray.push(leWeek[i][0]);
		}

		// Nevermind that's stupid lmao
		PlayState.storyPlaylist = songArray;
		PlayState.isStoryMode = true;
		selectedWeek = true;

		var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
		if(diffic == null) diffic = '';

		var desc = weekName;
		if(desc == null) desc = '';

		PlayState.storyDifficulty = curDifficulty;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState(), true);
			FreeplayState.destroyFreeplayVocals();
		});
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = CoolUtil.difficulties[curDifficulty];

		difficultyText.text = diff;
		difficultyText.x = diffBg.x + 206 - (difficultyText.width / 2);
		difficultyText.alpha = 0;
		difficultyText.y = tracksSprite.y + (tracksSprite.height / 2) - (difficultyText.height / 2) + 15;

		difficultyText.borderColor = getDiffColor();

		leftArrow.borderColor = difficultyText.borderColor;
		rightArrow.borderColor = difficultyText.borderColor;

		if(tweenDifficulty != null) tweenDifficulty.cancel();
		tweenDifficulty = FlxTween.tween(difficultyText, {y: difficultyText.y - 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween) {
			tweenDifficulty = null;
		}});
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	function getDiffColor():Int
	{
		var diffColors:Array<String> = CoolUtil.coolTextFile(Paths.txt('diffColors'));
		var diffColor = diffColors[curDifficulty];
		if(!diffColor.startsWith('0x')) {
			diffColor = '0xFF' + diffColor;
		}
		//trace(diffColor);
		return Std.parseInt(diffColor);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		for (i in 0...grpWeekList.length) {
			var alpha = 0.3;
			if (i == curWeek-1 || i == curWeek+1) alpha = 0.7;
			if (i == curWeek) alpha = 1;
			grpWeekList.members[i].alpha = alpha;
			grpWeekText.members[i].alpha = alpha;
		}

		camFollow.setPosition(grpWeekList.members[curWeek].x - 70, grpWeekList.members[curWeek].y + 90);

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;

		var bullShit:Int = 0;

		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		newColor = FlxColor.fromRGB(leWeek.songs[0][2][0], leWeek.songs[0][2][1], leWeek.songs[0][2][2]);
		var bgPath = 'storymenu/' + WeekData.weeksList[curWeek];
		var bgExists:Bool = Paths.fileExists('images/' + bgPath + '.png', IMAGE);
		if (bgExists) newBg.loadGraphic(Paths.image(bgPath));
		else newBg.loadGraphic(Paths.image(noBgSprite));
		noBg = !bgExists;

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x = tracksSprite.x + (tracksSprite.width / 2) - (txtTracklist.width / 2);

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
