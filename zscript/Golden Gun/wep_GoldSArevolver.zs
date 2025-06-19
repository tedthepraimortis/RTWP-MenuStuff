// ------------------------------------------------------------
// Golden Single Action Revolver
// ------------------------------------------------------------
class HDGoldSingleActionRevolver:HDHandgun{
	bool cylinderopen; //don't use weaponstatus since it shouldn't be saved anyway
	default{
		+hdweapon.fitsinbackpack
		+hdweapon.reverseguninertia
		scale 0.5;
		weapon.selectionorder 49;
		weapon.slotnumber 2;
		weapon.slotpriority 4;
		weapon.kickback 30;
		weapon.bobrangex 0.1;
		weapon.bobrangey 0.6;
		weapon.bobspeed 2.5;
		weapon.bobstyle "normal";
		obituary "$OB_GOLDENGUN";
		inventory.pickupmessage "$PICKUP_GOLDENSINGLEACTION";
		tag "$TAG_GOLDSINGLEACTION";
		hdweapon.refid "gsa";//golden single action
		hdweapon.barrelsize 20,0.3,0.5;
	}
	override double gunmass(){
		double blk=0;
		for(int i=GSAS_CYL1;i<=GSAS_CYL6;i++){
			int wi=weaponstatus[i];
			if(wi==GSAS_MASTERBALL)blk+=0.3;
			else if(wi==GSAS_NINEMIL)blk+=0.3;
		}
		return blk+9;
	}
	override double weaponbulk(){
		double blk=0;
		for(int i=GSAS_CYL1;i<=GSAS_CYL6;i++){
			int wi=weaponstatus[i];
			if(wi==GSAS_MASTERBALL)blk+=ENC_355_LOADED*2;
			else if(wi==GSAS_NINEMIL)blk+=ENC_355_LOADED*2;
		}
		return blk+55;//more bulk due to being made of fucking gold
	}
	override string,double getpickupsprite(){
		return "GSALA0",1.;
	}

	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("GC45A0",(-47,-10),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			sb.drawnum(hpl.countinv("HDGold45LCAmmo"),-44,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			int ninemil=hpl.countinv("HDGold45LCAmmo");
		}
		int plf=hpl.player.getpsprite(PSP_WEAPON).frame;
		for(int i=GSAS_CYL1;i<=GSAS_CYL6;i++){
			double drawangle=i*(360./6.)-150;
			vector2 cylpos;
			if(plf==4){
				drawangle-=45.;
				cylpos=(-30,-14);
			}else if(cylinderopen){
				drawangle-=90;
				cylpos=(-34,-12);
			}else{
				cylpos=(-22,-20);
			}
			double cdrngl=cos(drawangle);
			double sdrngl=sin(drawangle);
			if(
				!cylinderopen
				&&sb.hud_aspectscale.getbool()
			){
				cdrngl*=1.1;
				sdrngl*=(1./1.1);
			}
			vector2 drawpos=cylpos+(cdrngl,sdrngl)*5;
			sb.fill(
				hdw.weaponstatus[i]>0?
				color(255,240,230,40)
				:color(200,30,26,24),
				drawpos.x,
				drawpos.y,
				3,3,
				sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_RIGHT
			);
		}
	}

	override string gethelptext(){
		LocalizeHelp();
		if(cylinderopen)return
		LWPHELP_FIRE..Stringtable.Localize("$GSAR_HELPTEXT_1")
		..LWPHELP_ALTFIRE..Stringtable.Localize("$GSAR_HELPTEXT_2")..LWPHELP_ZOOM..Stringtable.Localize("$GSAR_HELPTEXT_3")
		..LWPHELP_UNLOAD..Stringtable.Localize("$GSAR_HELPTEXT_4")
		..LWPHELP_RELOAD..Stringtable.Localize("$GSAR_HELPTEXT_5")
		;
		return
		LWPHELP_FIRESHOOT
		..LWPHELP_ALTFIRE..Stringtable.Localize("$GSAR_HELPTEXT_6")
		..LWPHELP_ALTRELOAD.."/"..LWPHELP_FIREMODE..Stringtable.Localize("$GSAR_HELPTEXT_7")
		..LWPHELP_UNLOAD.."/"..LWPHELP_RELOAD..Stringtable.Localize("$GSAR_HELPTEXT_8")
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		if(HDGoldSingleActionRevolver(hdw).cylinderopen)return;

		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		vector2 scc;
		vector2 bobb=bob*1.3;

		sb.SetClipRect(
			-8+bob.x,-9+bob.y,16,15,
			sb.DI_SCREEN_CENTER
		);
		scc=(0.9,0.9);

		sb.drawimage(
			"gsafst",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9,scale:scc
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"gsabkst",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,6,12);
			if(owner.countinv("HDGold45LCAmmo"))owner.A_DropInventory("HDGold45LCAmmo",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("HDGold45LCAmmo",6);
	}
	override void initializewepstats(bool idfa){
		weaponstatus[GSAS_CYL1]=GSAS_MASTERBALL;
		weaponstatus[GSAS_CYL2]=GSAS_MASTERBALL;
		weaponstatus[GSAS_CYL3]=GSAS_MASTERBALL;
		weaponstatus[GSAS_CYL4]=GSAS_MASTERBALL;
		weaponstatus[GSAS_CYL5]=GSAS_MASTERBALL;
		weaponstatus[GSAS_CYL6]=GSAS_MASTERBALL;
	}

	action bool HoldingRightHanded(){
		bool righthanded=invoker.wronghand;
		righthanded=
		(
			righthanded
			&&Wads.CheckNumForName("id",0)!=-1
		)||(
			!righthanded
			&&Wads.CheckNumForName("id",0)==-1
		);
		return righthanded;
	}
	action void A_CheckRevolverHand(){
		bool righthanded=HoldingRightHanded();
		if(righthanded)player.getpsprite(PSP_WEAPON).sprite=getspriteindex("GRVGA0");
		else player.getpsprite(PSP_WEAPON).sprite=getspriteindex("GSAGA0");
	}
	action void A_RotateCylinder(bool clockwise=true){
		invoker.RotateCylinder(clockwise);
		A_StartSound("weapons/goldsingleact_cyl",8);
	}
	void RotateCylinder(bool clockwise=true){
		if(clockwise){
			int cylbak=weaponstatus[GSAS_CYL1];
			weaponstatus[GSAS_CYL1]=weaponstatus[GSAS_CYL6];
			weaponstatus[GSAS_CYL6]=weaponstatus[GSAS_CYL5];
			weaponstatus[GSAS_CYL5]=weaponstatus[GSAS_CYL4];
			weaponstatus[GSAS_CYL4]=weaponstatus[GSAS_CYL3];
			weaponstatus[GSAS_CYL3]=weaponstatus[GSAS_CYL2];
			weaponstatus[GSAS_CYL2]=cylbak;
		}else{
			int cylbak=weaponstatus[GSAS_CYL1];
			weaponstatus[GSAS_CYL1]=weaponstatus[GSAS_CYL2];
			weaponstatus[GSAS_CYL2]=weaponstatus[GSAS_CYL3];
			weaponstatus[GSAS_CYL3]=weaponstatus[GSAS_CYL4];
			weaponstatus[GSAS_CYL4]=weaponstatus[GSAS_CYL5];
			weaponstatus[GSAS_CYL5]=weaponstatus[GSAS_CYL6];
			weaponstatus[GSAS_CYL6]=cylbak;
		}
	}
	action void A_LoadRound(){
		if(invoker.weaponstatus[GSAS_CYL1]>0)return;
		bool useninemil=(
			player.cmd.buttons&BT_FIREMODE
			||!countinv("HDGold45LCAmmo")
		);
		class<inventory>ammotype=useninemil?"HDGold45LCAmmo":"HDGold45LCAmmo";
		A_TakeInventory(ammotype,1,TIF_NOTAKEINFINITE);
		invoker.weaponstatus[GSAS_CYL1]=useninemil?GSAS_NINEMIL:GSAS_MASTERBALL;
		A_StartSound("weapons/goldsingleact_load",8,CHANF_OVERLAP);
	}
	action void A_OpenCylinder(){
		A_StartSound("weapons/goldsingleact_open",8);
		invoker.weaponstatus[0]&=~GSAF_COCKED;
		invoker.cylinderopen=true;
		A_SetHelpText();
	}
	action void A_CloseCylinder(){
		A_StartSound("weapons/goldsingleact_close",8);
		invoker.cylinderopen=false;
		A_SetHelpText();
	}
	action void A_HitExtractor(){
		double cosp=cos(pitch);
		for(int i=GSAS_CYL1;i<=GSAS_CYL1;i++){
			int thischamber=invoker.weaponstatus[i];
			if(thischamber==1)continue;
			if(
				thischamber==GSAS_NINEMILSPENT
				||thischamber==GSAS_NINEMIL
     ||thischamber==GSAS_MASTERBALL
				||thischamber==GSAS_MASTERBALLSPENT
			){
				actor aaa=spawn(
					thischamber==GSAS_NINEMIL?"HDGold45LCAmmo"
        :thischamber==GSAS_MASTERBALL?"HDGold45LCAmmo"
						:thischamber==GSAS_MASTERBALLSPENT?"HDSpentGold45LC"
						:"HDGoldSpent45LC",
					(pos.xy,pos.z+height-10)
					+(cosp*cos(angle),cosp*sin(angle),sin(pitch))*7,
					ALLOW_REPLACE
				);
				aaa.vel=vel+(frandom(-1,1),frandom(-1,1),-1);
				aaa.angle=angle;
				invoker.weaponstatus[i]=0;
			}
		}
		A_StartSound("weapons/goldsingleact_eject",8,CHANF_OVERLAP);
	}
	action void A_ExtractAll(){
		double cosp=cos(pitch);
		bool gotany=false;
		for(int i=GSAS_CYL1;i<=GSAS_CYL6;i++){
			int thischamber=invoker.weaponstatus[i];
			if(thischamber<1)continue;
			if(
				thischamber==GSAS_NINEMILSPENT
				||thischamber==GSAS_MASTERBALLSPENT
			){
				actor aaa=spawn("HDSpent9mm",
					(pos.xy,pos.z+height-14)
					+(cosp*cos(angle),cosp*sin(angle),sin(pitch)-2)*3,
					ALLOW_REPLACE
				);
				aaa.vel=vel+(frandom(-0.3,0.3),frandom(-0.3,0.3),-1);
				if(thischamber==GSAS_MASTERBALLSPENT)aaa.scale.y=0.85;
				invoker.weaponstatus[i]=0;
			}else{
				//give or spawn either 9mm or 355
				class<inventory>ammotype=
					thischamber==GSAS_MASTERBALL?
					"HDGold45LCAmmo":"HDGold45LCAmmo";
				if(A_JumpIfInventory(ammotype,0,"null")){
					actor aaa=spawn(ammotype,
						(pos.xy,pos.z+height-14)
						+(cosp*cos(angle),cosp*sin(angle),sin(pitch)-2)*3,
						ALLOW_REPLACE
					);
					aaa.vel=vel+(frandom(-1,1),frandom(-1,1),-1);
				}else{
					A_GiveInventory(ammotype,1);
					gotany=true;
				}
				invoker.weaponstatus[i]=0;
			}
		}
		if(gotany)A_StartSound("weapons/pocket",9);
	}
	action void A_FireRevolver(){
		invoker.weaponstatus[0]&=~GSAF_COCKED;
		int cyl=invoker.weaponstatus[GSAS_CYL1];
		if(
			cyl!=GSAS_MASTERBALL
			&&cyl!=GSAS_NINEMIL
		){
			A_StartSound("weapons/rsa_click",8,CHANF_OVERLAP);
			return;
		}
		invoker.weaponstatus[GSAS_CYL1]--;
		bool masterball=cyl==GSAS_MASTERBALL;

		let bbb=HDBulletActor.FireBullet(self,masterball?"HDB_Gold45lc":"HDB_Gold45lc", spread:1., speedfactor:frandom(1.49,1.51));
                           //it's golden, it's better
		if(
			frandom(0,ceilingz-floorz)<bbb.speed*(masterball?0.4:0.4)
		)A_AlertMonsters(masterball?512:512);

		A_GunFlash();
		A_Light1();
		A_ZoomRecoil(1.995);
		HDFlashAlpha(masterball?72:72);
		A_StartSound("weapons/goldengun", CHAN_WEAPON, CHANF_OVERLAP);
		if(hdplayerpawn(self)){
			hdplayerpawn(self).gunbraced=false;
		}
  	A_MuzzleClimb(-frandom(4.2,5.5), 
                  -frandom(4.6,5.9), 
                  -frandom(4.2,5.5));
	}

	int cooldown;
	action void A_ReadyOpen(){
		A_WeaponReady(WRF_NOFIRE|WRF_ALLOWUSER3);
		if(justpressed(BT_ALTATTACK))setweaponstate("open_rotatecylinder");
		else if(justpressed(BT_RELOAD)){
			if(
				(
					invoker.weaponstatus[GSAS_CYL1]>0
					&&invoker.weaponstatus[GSAS_CYL2]>0
					&&invoker.weaponstatus[GSAS_CYL3]>0
					&&invoker.weaponstatus[GSAS_CYL4]>0
					&&invoker.weaponstatus[GSAS_CYL5]>0
					&&invoker.weaponstatus[GSAS_CYL6]>0
				)||(
					!countinv("HDGold45LCAmmo")
					&&!countinv("HDGold45LCAmmo")
				)
			)setweaponstate("open_closecylinder");
			else setweaponstate("open_loadround");
		}else if(justpressed(BT_ATTACK))setweaponstate("open_closecylinder");
		else if(justpressed(BT_UNLOAD)){
			if(!invoker.cooldown){
				setweaponstate("open_dumpcylinder");
				invoker.cooldown=3;
			}
		}
		if(invoker.cooldown>0)invoker.cooldown--;
	}
	action void A_RoundReady(int rndnm){
		int gunframe=-1;
		if(invoker.weaponstatus[rndnm]>0)gunframe=player.getpsprite(PSP_WEAPON).frame;
		let thissprite=player.getpsprite(GSAS_OVRCYL+rndnm);
		switch(gunframe){
		case 4: //E
			thissprite.frame=0;
			break;
		case 5: //F
			thissprite.frame=1;
			break;
		case 6: //G
			thissprite.frame=pressingzoom()?4:2;
			break;
		default:
			thissprite.sprite=getspriteindex("TNT1A0");
			thissprite.frame=0;
			return;break;
		}
	}
	action void A_CockHammer(bool yes=true){
		if(yes)invoker.weaponstatus[0]|=GSAF_COCKED;
		else invoker.weaponstatus[0]&=~GSAF_COCKED;
	}


/*
	A normal ready
	B ready cylinder midframe
	C hammer fully cocked (maybe renumber these lol)
	D recoil frame
	E cylinder swinging out - left hand passing to right
	F cylinder swung out - held in right hand, working chamber in middle
	G cylinder swung out midframe
*/
	states{
	spawn:
		GSAL A -1;
		stop;//chambered round sprites go here
	round1:GSR1 A 1 A_RoundReady(GSAS_CYL1);wait;
	round2:GSR2 A 1 A_RoundReady(GSAS_CYL2);wait;
	round3:GSR3 A 1 A_RoundReady(GSAS_CYL3);wait;
	round4:GSR4 A 1 A_RoundReady(GSAS_CYL4);wait;
	round5:GSR5 A 1 A_RoundReady(GSAS_CYL5);wait;
	round6:GSR6 A 1 A_RoundReady(GSAS_CYL6);wait;
	select0:
		GSAG A 0{
			if(!countinv("NulledWeapon"))invoker.wronghand=true;//ready in right hand instead of left
			A_TakeInventory("NulledWeapon");
			A_CheckRevolverHand();
			invoker.cylinderopen=false;
			invoker.weaponstatus[0]&=invoker.weaponstatus[0];

			//uncock all spare revolvers
			if(findinventory("SpareWeapons")){
				let spw=SpareWeapons(findinventory("SpareWeapons"));
				for(int i=0;i<spw.weapontype.size();i++){
					if(spw.weapontype[i]==invoker.getclassname()){
						string spw2=spw.weaponstatus[i];
						string spw1=spw2.left(spw2.indexof(","));
						spw2=spw2.mid(spw2.indexof(","));
						int stat0=spw1.toint();
						stat0&=stat0;
						spw.weaponstatus[i]=stat0..spw2;
					}
				}
			}

			A_Overlay(GSAS_OVRCYL+GSAS_CYL1,"round1");
			A_Overlay(GSAS_OVRCYL+GSAS_CYL2,"round2");
			A_Overlay(GSAS_OVRCYL+GSAS_CYL3,"round3");
			A_Overlay(GSAS_OVRCYL+GSAS_CYL4,"round4");
			A_Overlay(GSAS_OVRCYL+GSAS_CYL5,"round5");
			A_Overlay(GSAS_OVRCYL+GSAS_CYL6,"round6");
		}
		---- A 1 A_Raise();
		---- A 1 A_Raise(40);
		---- A 1 A_Raise(40);
		---- A 1 A_Raise(25);
		---- A 1 A_Raise(20);
		wait;
	deselect0:
		GSAG A 0 A_CheckRevolverHand();
		#### D 0 A_JumpIf(!invoker.cylinderopen,"deselect0a");
		GSAG F 1 A_CloseCylinder();
		GSAG E 1;
		GSAG A 0 A_CheckRevolverHand();
		goto deselect0a;
	deselect0a:
		#### AD 1 A_Lower();
		---- A 1 A_Lower(20);
		---- A 1 A_Lower(34);
		---- A 1 A_Lower(50);
		wait;
	ready:
		GSAG A 0 A_CheckRevolverHand();
		---- A 0 A_JumpIf(invoker.cylinderopen,"readyopen");
		#### C 0 A_JumpIf(invoker.weaponstatus[0]&GSAF_COCKED,2);
		#### A 0;
		---- A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1|WRF_ALLOWUSER2|WRF_ALLOWUSER3|WRF_ALLOWUSER4);
		goto readyend;
	fire:
		#### A 1 A_JumpIf(invoker.weaponstatus[0]&GSAF_COCKED,"hammertime");
  #### A 1 A_JumpIf(pressingaltfire(),"altfire");
  #### A 1 A_JumpIf(!pressingfire(),"nope");
		//#### A 1 offset(0,34);
		//#### A 0 offset(0,32);
  goto fire;
	hammertime:
		#### A 0 A_ClearRefire();
		#### A 1 A_FireRevolver();
		goto fire;
	firerecoil:
		#### D 2;
		#### A 0;
		goto ready;
	flash:
		GLDF A 1 bright;
		---- A 0 A_Light0();
		---- A 0 setweaponstate("firerecoil");
		stop;
		GRVG ABCD 0;
		stop;
	altfire:
		---- A 0 A_JumpIf(invoker.weaponstatus[0]&GSAF_COCKED,"uncock");
		#### B 1 offset(0,34) A_ClearRefire();
		#### B 2 offset(0,36) A_RotateCylinder();
	cocked:
		#### C 0 {A_CockHammer(); A_StartSound("weapons/rsa_click",8,CHANF_OVERLAP);}
		---- A 0 A_JumpIf(pressingaltfire(),"nope");
		goto readyend;
	uncock:
		#### C 1 offset(0,38);
		#### B 1 offset(0,34);
		#### A 2 offset(0,36) A_StartSound("weapons/goldsingleact_click",8,CHANF_OVERLAP);
		#### A 0 A_CockHammer(false);
		goto nope;
	reload:
	unload:
		#### C 0 A_JumpIf(!(invoker.weaponstatus[0]&GSAF_COCKED),3);
		#### B 1 offset(0,35)A_CockHammer(false);
		#### A 1 offset(0,33);
		#### A 1 A_JumpIf(player.getpsprite(PSP_WEAPON).sprite!=getspriteindex("GRVGA0"),"openslow");
		GSAG E 2 A_OpenCylinder();
		goto readyopen;
	openslow:
		GSAG A 1 offset(2,39);
		GSAG A 1 offset(4,50);
		GSAG A 1 offset(8,64);
		GSAG A 1 offset(10,86);
		GSAG A 1 offset(12,96);
		GSAG E 1 offset(-7,66);
		GSAG E 1 offset(-6,56);
		GSAG E 1 offset(-2,40);
		GSAG E 1 offset(0,32);
		GSAG E 1 A_OpenCylinder();
		goto readyopen;
	readyopen:
		GSAG F 1 A_ReadyOpen();
		goto readyend;
	open_rotatecylinder:
		GSAG G 1 A_RotateCylinder(pressingzoom());
		GSAG F 1 A_JumpIf(!pressingaltfire(),"readyopen");
		goto readyopen;
	open_loadround:
		GSAG F 1 A_LoadRound();
		//goto open_rotatecylinder;
  goto readyopen;
	open_closecylinder:
		GSAG E 2 A_JumpIf(pressingfire(),"open_fastclose");
		GSAG E 0 A_CloseCylinder();
		GSAG A 0 A_CheckRevolverHand();
		#### A 0 A_JumpIf(player.getpsprite(PSP_WEAPON).sprite==getspriteindex("GRVGA0"),"nope");
		GSAG E 1 offset(0,32);
		GSAG E 1 offset(-2,40);
		GSAG E 1 offset(-6,56);
		GSAG E 1 offset(-7,66);
		GSAG A 1 offset(12,96);
		GSAG A 1 offset(10,86);
		GSAG A 1 offset(8,64);
		GSAG A 1 offset(4,50);
		GSAG A 1 offset(2,39);
		goto nope;
	open_fastclose:
		GSAG E 2;
		GSAG A 0{
			A_CloseCylinder();
			invoker.wronghand=(Wads.CheckNumForName("id",0)!=-1);
			A_CheckRevolverHand();
		}goto nope;
	open_dumpcylinder:
		GSAG F 1 A_HitExtractor();
		goto readyopen;
	open_dumpcylinder_all:
		GSAG F 1 offset(0,34);
		GSAG F 1 offset(0,42);
		GSAG F 1 offset(0,54);
		GSAG F 1 offset(0,68);
		TNT1 A 6 A_ExtractAll();
		GSAG F 1 offset(0,68);
		GSAG F 1 offset(0,54);
		GSAG F 1 offset(0,42);
		GSAG F 1 offset(0,34);
		goto readyopen;

	user1:
	user2:
	swappistols:
		---- A 0 A_SwapHandguns();
		#### D 0 A_JumpIf(player.getpsprite(PSP_WEAPON).sprite==getspriteindex("GRVGA0"),"swappistols2");
	swappistols1:
		TNT1 A 0 A_Overlay(1025,"raiseright");
		TNT1 A 0 A_Overlay(1026,"lowerleft");
		TNT1 A 5;
		GRVG C 0 A_JumpIf(invoker.weaponstatus[0]&GSAF_COCKED,"nope");
		GRVG A 0;
		goto nope;
	swappistols2:
		TNT1 A 0 A_Overlay(1025,"raiseleft");
		TNT1 A 0 A_Overlay(1026,"lowerright");
		TNT1 A 5;
		GSAG C 0 A_JumpIf(invoker.weaponstatus[0]&GSAF_COCKED,"nope");
		GSAG A 0;
		goto nope;
	lowerleft:
		GSAG C 0 A_JumpIf(invoker.weaponstatus[0]&GSAF_COCKED,2);
		GSAG A 0;
		---- A 1 offset(-6,38);
		---- A 1 offset(-12,48);
		GSAG D 1 offset(-20,60);
		GSAG D 1 offset(-34,76);
		GSAG D 1 offset(-50,86);
		stop;
	lowerright:
		GRVG C 0 A_JumpIf(invoker.weaponstatus[0]&GSAF_COCKED,2);
		GRVG A 0;
		---- A 1 offset(6,38);
		---- A 1 offset(12,48);
		GRVG D 1 offset(20,60);
		GRVG D 1 offset(34,76);
		GRVG D 1 offset(50,86);
		stop;
	raiseleft:
		GSAG D 1 offset(-50,86);
		GSAG D 1 offset(-34,76);
		GSAG C 0 A_JumpIf(invoker.weaponstatus[0]&GSAF_COCKED,2);
		GSAG A 0;
		---- A 1 offset(-20,60);
		---- A 1 offset(-12,48);
		---- A 1 offset(-6,38);
		stop;
	raiseright:
		GRVG D 1 offset(50,86);
		GRVG D 1 offset(34,76);
		GRVG C 0 A_JumpIf(invoker.weaponstatus[0]&GSAF_COCKED,2);
		GRVG A 0;
		---- A 1 offset(20,60);
		---- A 1 offset(12,48);
		---- A 1 offset(6,38);
		stop;
	whyareyousmiling:
		#### D 1 offset(0,38);
		#### D 1 offset(0,48);
		#### D 1 offset(0,60);
		TNT1 A 7;
		GSAG A 0{
			invoker.wronghand=!invoker.wronghand;
			A_CheckRevolverHand();
		}
		#### D 1 offset(0,60);
		#### D 1 offset(0,48);
		#### D 1 offset(0,38);
		goto nope;
	}
}


enum GoldSingleActionStats{
	//chamber 1 is the shooty one
	GSAS_CYL1=1,
	GSAS_CYL2=2,
	GSAS_CYL3=3,
	GSAS_CYL4=4,
	GSAS_CYL5=5,
	GSAS_CYL6=6,
	GSAS_OVRCYL=355,

	//odd means spent
	GSAS_NINEMILSPENT=1,
	GSAS_NINEMIL=2,
	GSAS_MASTERBALLSPENT=3,
	GSAS_MASTERBALL=4,

	GSAF_RIGHTHANDED=1,
	GSAF_COCKED=2,
}


class GoldSADeinoSpawn:actor{
	override void postbeginplay(){
		super.postbeginplay();
		let box=spawn("HDGold45LCBoxPickup",pos,ALLOW_REPLACE);
		if(box)HDF.TransferSpecials(self,box);
		spawn("HDGoldSingleActionRevolver",pos,ALLOW_REPLACE);
		self.Destroy();
	}
}

class HDGoldenGunRandomDrop:RandomSpawner{
	default{
		dropitem "HDPistol",16,5;
		dropitem "HDGoldSingleActionRevolver",4,1;
	}
}
