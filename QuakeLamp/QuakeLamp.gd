tool
extends Spatial

class_name cQuakeLamp

#-------------------------------------------------------

enum LampAnimation{
	None,
	Flicker1,
	SlowStrongPulse,
	Candle1,
	FastStrobe,
	GentlePulse1,
	Flicker2,
	Candle2,
	Candle3,
	SlowStrobe,
	FluorescentFlicker,
	SlowPulse,
	Custom
}

#-------------------------------------------------------

var mvLights : Array = [];
var mvMeshInstances : Array = [];
var mbSwitchedOn : bool = true;
var mfTimePassed : float = 0.0;
var mfEnergy : float = 1.0;
var mpSPB = StreamPeerBuffer.new();

export(Color) var LightColor = Color(1,1,1);
export(Color) var EmissionColor = Color(1,1,1);
export(float) var EnergyMultiplier = 1.0;

export(bool) var AnimateInTheEditor = false;
export(LampAnimation) var LightAnimation = LampAnimation.None;
export(String) var CustomEnergyAnimationString = "abcdefghijklm";
export(float) var TimeOffset = 0.0;

export(bool) var Fade = false;
export(float) var FadeSpeed = 60.0;

#-------------------------------------------------------

func _ready()->void:
	var vChildren : Array = get_children();
	
	for i in range(vChildren.size()-1, -1, -1):
		var pCurrChild = vChildren[i];
		if (is_instance_valid(pCurrChild)==false): continue;

		#/////////////////
		# List light nodes
		if (pCurrChild.get_class()=="OmniLight" || pCurrChild.get_class()=="SpotLight"):
			mvLights.push_back(pCurrChild);
			
		#/////////////////////
		# List mesh inst nodes
		if (pCurrChild.get_class()=="MeshInstance"):
			mvMeshInstances.push_back(pCurrChild);
	
	SetLight(EnergyMultiplier, LightColor);
	SetMaterialEmission(EnergyMultiplier, EmissionColor);
	
#-------------------------------------------------------

func _process(_afTimeStep : float)->void:
	#////////////////////////////
	# Don't animate in the editor
	if (Engine.editor_hint && AnimateInTheEditor==false): 
		var fDesiredEnergy = GetEnergyLevel("m") * EnergyMultiplier;	
		SetLight(fDesiredEnergy, LightColor);
		SetMaterialEmission(fDesiredEnergy, EmissionColor);
		return;
	
	#/////////////////////////
	# Quake styled light anims
	# 'm' is normal light, 'a' is no light, 'z' is double bright
	mfTimePassed += _afTimeStep;
	var fTimePassed = TimeOffset + mfTimePassed;
	
	var sAnimType : String = "m";
	
	# 1 FLICKER (first variety)
	if (LightAnimation==1):
		sAnimType = "mmnmmommommnonmmonqnmmo";
	# 2 SLOW STRONG PULSE
	elif (LightAnimation==2):
		sAnimType = "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba";
	# 3 CANDLE (first variety)
	elif (LightAnimation==3):
		sAnimType = "mmmmmaaaaammmmmaaaaaabcdefgabcdefg";
	# 4 FAST STROBE
	elif (LightAnimation==4):
		sAnimType = "mamamamamama";
	# 5 GENTLE PULSE 1
	elif (LightAnimation==5):
		sAnimType = "jklmnopqrstuvwxyzyxwvutsrqponmlkj";
	# 6 FLICKER (second variety)
	elif (LightAnimation==6):
		sAnimType = "nmonqnmomnmomomno";
	# 7 CANDLE (second variety)
	elif (LightAnimation==7):
		sAnimType = "mmmaaaabcdefgmmmmaaaammmaamm";
	# 8 CANDLE (third variety)
	elif (LightAnimation==8):
		sAnimType = "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa";
	# 9 SLOW STROBE (fourth variety)
	elif (LightAnimation==9):
		sAnimType = "aaaaaaaazzzzzzzz";
	# 10 FLUORESCENT FLICKER
	elif (LightAnimation==10):
		sAnimType = "mmamammmmammamamaaamammma";
	# 11 SLOW PULSE NOT FADE TO BLACK
	elif (LightAnimation==11):
		sAnimType = "abcdefghijklmnopqrrqponmlkjihgfedcba";
	# CUSTOM
	elif (LightAnimation==12):
		sAnimType = CustomEnergyAnimationString;

	#/////////////////
	# Calculate Energy
	var fFrame : float = int(fTimePassed * 10); # 1 full cycle every 10 frames
	var lIt : int = int(fFrame) % sAnimType.length();
	var fDesiredEnergy = GetEnergyLevel(sAnimType[lIt]);
	
	
	if (Fade):
		if (is_equal_approx(fDesiredEnergy, mfEnergy)==false):
			var fStep : float = _afTimeStep * FadeSpeed;
			if (mfEnergy > fDesiredEnergy):
				mfEnergy = max(mfEnergy - fStep, fDesiredEnergy);
			elif (mfEnergy < fDesiredEnergy):
				mfEnergy = min(mfEnergy + fStep, fDesiredEnergy);
	else:
		mfEnergy = fDesiredEnergy;
		
	var fLampEnergy = mfEnergy * EnergyMultiplier;
	
	#///////////////////
	# Set Energy & Color
	SetLight(fLampEnergy, LightColor);
	SetMaterialEmission(fLampEnergy, LightColor);

#-------------------------------------------------------

#func _physics_process(_afTimeStep : float)->void:
#	pass

#-------------------------------------------------------

func GetEnergyLevel(sChar:String)->float:
	mpSPB.data_array = sChar.to_wchar();
	var lInt1 = mpSPB.get_8(); # TODO: Check if there's a better way to do this or potentially move to C++
	
	mpSPB.data_array = "a".to_wchar();
	var lInt2 = mpSPB.get_8();
	
	return float(lInt1 - lInt2) * 0.1;

#-------------------------------------------------------

func SetLight(afEnergy:float, aColor:Color=Color(-1,-1,-1)):
	for i in range(mvLights.size()-1, -1, -1):
		var pCurrLight : Light = mvLights[i];
		if (is_instance_valid(pCurrLight)==false): continue;
		
		pCurrLight.light_energy = afEnergy;
		
		if (aColor==Color(-1,-1,-1)): return;
		pCurrLight.light_color = aColor;
		
#-------------------------------------------------------

func SetMaterialEmission(afEnergy : float, aColor : Color = Color(-1,-1,-1))->void:
	for i in range(mvMeshInstances.size()-1, -1, -1):
		var pCurrMeshInst : MeshInstance = mvMeshInstances[i];
		if (is_instance_valid(pCurrMeshInst)==false): continue;
		
		for j in range(pCurrMeshInst.get_surface_material_count()-1, -1, -1):
			var pMat : SpatialMaterial = pCurrMeshInst.get_surface_material(j);
			if (is_instance_valid(pMat)==false): continue;
			
			pMat.set_emission_energy(afEnergy);
			
			if (aColor==Color(-1,-1,-1)): return;
			pMat.set_emission(aColor);

#-------------------------------------------------------
