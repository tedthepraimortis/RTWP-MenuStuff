// ------------------------------------------------------------
// Micro-Cell ammo for the Phazer pistol and other such gadgets
// ------------------------------------------------------------

class HDMicroCell:HDMagAmmo{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Micro-Cell"
		//$Sprite "MCLLA0"

		hdmagammo.maxperunit 10;
		hdmagammo.roundtype "";
		tag "$TAG_MICROCELL";
		inventory.pickupmessage "$PICKUP_MICROCELL";
		hdpickup.refid "MCL";
		hdpickup.bulk ENC_BATTERY/2;
		hdmagammo.magbulk ENC_BATTERY/2;
		hdmagammo.mustshowinmagmanager true;
		inventory.icon "MCLLA0";
		scale 0.4;
	}
	enum BatteryChargeModes{
		BATT_UNDEFINED=0,
		BATT_DONTCHARGE=1,
		BATT_CHARGEMAX=2,
		BATT_CHARGESELECTED=3,
		BATT_CHARGEDEFAULT=BATT_CHARGEMAX,
	}
	int ticker;
	int lastamount;
	int chargemode;
	override void doeffect(){
		//testingdoeffect();return;
		if(chargemode==BATT_UNDEFINED)chargemode=BATT_CHARGEDEFAULT;
		if(chargemode==BATT_DONTCHARGE){
			super.doeffect();
			return;
		}
		if(lastamount!=amount){
			ticker=0;
			lastamount=amount;
		}else if(ticker>350){
			ticker=0;
			ChargeMicroCell(1,chargemode==BATT_CHARGESELECTED);
		}else ticker++;
		super.doeffect();
	}
	override double getbulk(){return amount*bulk;}
	override bool Extract(){return false;}
	override bool Insert(){
		chargemode++;
		if(chargemode>BATT_CHARGESELECTED)chargemode=BATT_DONTCHARGE;
		return false;
	}
	override void Consolidate(){
	//not compatible with BFG auto-charge
		ChargeMicroCell(usetop:true);
		ChargeMicroCell();
	}
	
	void ChargeMicroCell(int chargestodo=-1,bool usetop=false){
		SyncAmount();
		if(amount<1)return;

		int batcount=0;
		int totalchargeable=0;
		int biggestindex=-1;
		int biggestamt=0;
		int smallestindex=-1;
		int smallestamt=10;
		int maxindex=amount-1;

		//get the smallest and biggest amounts, and number usable for this
		for(int i=0;i<amount;i++){
			int chargeamt=mags[i];
			if(chargeamt>0){
				totalchargeable+=chargeamt;
				batcount++;
				if(
					!usetop
					&&biggestamt<chargeamt
					&&chargeamt<10
				){
					biggestamt=chargeamt;
					biggestindex=i;
				}
				if(
					smallestamt>=chargeamt
				){
					smallestamt=chargeamt;
					smallestindex=i;
				}
			}
		}
		if(usetop){
			biggestindex=maxindex;
			biggestamt=mags[maxindex];
		}
		if(
			biggestindex<0
			||smallestindex<0
			||smallestamt>=10
			||biggestamt>=10
			||biggestindex==smallestindex
		){
			if(chargemode==BATT_CHARGESELECTED){
				if(biggestamt>=10){
					owner.A_Log(Stringtable.Localize("$MBAT_USERERROR_1"),true);
				}else if(
					biggestindex==smallestindex
					&&biggestindex==maxindex
				){
					owner.A_Log(Stringtable.Localize("$MBAT_USERERROR_2"),true);
				}
				chargemode=BATT_CHARGEMAX;
			}
			return;
		}
		if(
			batcount<3	//need at least 3 to increase any one
			||totalchargeable-biggestamt-2<biggestamt	//min. chargor value must exceed target amount
		)return;

		//keep going until exactly ONE battery is fully drained or charged
		while(
			chargestodo
			&&mags[smallestindex]>0
			&&mags[biggestindex]<10
		){
			chargestodo--;
			mags[smallestindex]--;
			if(random(0,39))mags[biggestindex]++;
		}
		if(hd_debug)LogAmounts();
	}
	
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite="MCLLA0";
		if(thismagamt>6)magsprite="MCLLA0";
		else if(thismagamt>3)magsprite="MCLLB0";
		else if(thismagamt>0)magsprite="MCLLC0";
		else magsprite="MCLLD0";
		return magsprite,"MCLPA0","HDMicroCell",0.8;
	}
	override void DrawRoundCount(HDStatusBar sb,HDPlayerPawn hpl,name roundsprite,double scl,int offx,int offy){
		bool helptext=hpl.hd_helptext.getbool();
		offx+=40;
		scl=1;
		let battt=chargemode;
		string batts="uNone";
		if(battt==hdbattery.BATT_CHARGEMAX)batts="eAuto";
		else if(battt==hdbattery.BATT_CHARGESELECTED)batts="ySelected";
		sb.DrawString(
			sb.psmallfont,string.format(Stringtable.Localize("$MBAT_HELPTEXT_1"),helptext?Stringtable.Localize("$MBAT_HELPTEXT_2"):"",batts,helptext?Stringtable.Localize("$MBAT_HELPTEXT_3"):""),(offx+2,offy),
			sb.DI_SCREEN_CENTER|sb.DI_TEXT_ALIGN_LEFT,
			wrapwidth:smallfont.StringWidth("m")*80
		);

		sb.drawimage("MCLLA0",(offx,offy),
			sb.DI_SCREEN_CENTER|sb.DI_ITEM_RIGHT_TOP,
			scale:(scl,scl)
		);
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("PhazerPistol");
		itemsthatusethis.push("HDStunGun");
	}
	
	states(actor){
	spawn:
		MCLL CAB -1 nodelay{
			if(!mags.size()){destroy();return;}
			int amt=mags[0];
			if(amt>6)frame=0;
			else if(amt>3)frame=1;
		}stop;
	spawnempty:
		MCLL D -1;
		stop;
	}
}
