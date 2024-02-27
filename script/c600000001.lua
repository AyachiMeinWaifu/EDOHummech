--Demo Man
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.con)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
end

--check if is main phase
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
--select destroy target
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler() --register itself as c
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil) --register target as g
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    -- you need to have the info for both possible choices
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()  --define itself
	local tc=Duel.GetFirstTarget()  --define des target
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        local b1=tc:IsAbleToGrave() --tograve check
        local b2=(Duel.GetLocationCount(tp,LOCATION_MZONE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false))   --spsummon check
        local op=Duel.SelectEffect(tp,
            {b1,aux.Stringid(id,1)},
            {b2,aux.Stringid(id,2)})
        if op==1 then
		    Duel.SendtoGrave(c,REASON_EFFECT)
	    elseif op==2 then
		    Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	    end
	end
end