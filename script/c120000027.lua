--Dragonflymech Immobilizer
local s,id=GetID()
function s.initial_effect(c)
	--destroy 1 card & special summon or discard
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- quick effect when field spell
	-- tbd

	-- mandatory negate 1 card during end phase if control a machine when special summoned
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.sscon)
	e2:SetCountLimit(1,id+1)
	e2:SetOperation(s.sspop)
	c:RegisterEffect(e2)

	--Provide effect when used as material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(s.efcon)
	e3:SetOperation(s.efop1)
	c:RegisterEffect(e3)

	--Provide effect when used as material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCondition(s.efcon)
	e4:SetOperation(s.efop2)
	c:RegisterEffect(e4)
end
s.listed_series={0x10fc}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		local b0= c:IsLocation(LOCATION_HAND)
		local b1= c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local choice = 0
		if b0 and b1 then 
			choice = Duel.SelectOption(tp, aux.Stringid(id,4), aux.Stringid(id,5))
		else 
			choice = Duel.SelectOption(tp, aux.Stringid(id,5))+1
		end
		if choice == 0 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
		if choice == 1 then 
			Duel.SendtoGrave(c,REASON_EFFECT+REASON_DISCARD)
		end
	
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)

		-- Cannot Special Summon monsters, except Level/Rank/Link 1 monsters
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetDescription(aux.Stringid(id,2))
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e5:SetTargetRange(1,0)
		e5:SetTarget(function(_,c) return not (c:IsLevel(1) or c:IsRank(1) or c:IsLink(1)) end)
		e5:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e5,tp)
	end

end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
end

function s.filter(c)
	return c:IsFaceup()
	-- return c:IsFaceup() and not c:IsDisabled() and (c:IsNegatable())
end

function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,nil)
end

function s.sspop(e,tp,eg,ep,ev,re,r,rp)

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	-- Cannot Special Summon monsters, except Level/Rank/Link 1 monsters
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(_,c) return not (c:IsLevel(1) or c:IsRank(1) or c:IsLink(1)) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	
	local c=e:GetHandler()
	if #g>0 then
		Duel.HintSelection(g,true)
		--Duel.Destroy(g,REASON_EFFECT)
		local tc= g:GetFirst()
		-- if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) or tc:IsImmuneToEffect(e) then return end
		
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end

function s.tdtg(e,c)
	return c:GetRace()==RACE_MACHINE and (c:GetRank()==1 or c:GetLevel()==1 or c:GetLink()==1)
end

-- Provide effect when used as material
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler()
	return (r&REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK)~=0
	and p:GetReasonCard():IsAttribute(ATTRIBUTE_WIND)
end
function s.efop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--register the effect
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)

	--in case the monster did not have an effect
	if not rc:IsType(TYPE_EFFECT) then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
end

function s.efop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e2=Effect.CreateEffect(rc)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.operation2)
	rc:RegisterEffect(e2,true)

	--in case the monster did not have an effect
	if not rc:IsType(TYPE_EFFECT) then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
end

function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	if a:GetControler()==tp then
		e1:SetValue(d:GetDefense())
		a:RegisterEffect(e1)
	else
		e1:SetValue(a:GetDefense())
		d:RegisterEffect(e1)
	end
end