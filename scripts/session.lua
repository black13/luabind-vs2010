ret = dev:write(":POW:GAIN 1")
ret = dev:write("UNIT:POW DBM")
ret = dev:write("SENS:POW:ATT 10.00 DB")
ret = dev:write("SENS:SWE:TIME 600MS")
ret = dev:write(":BAND:RES 1MHZ")
ret = dev:write(":BAND:VID 3MHZ")
ret = dev:write(":INIT:CONT OFF")
ret = dev:write(":FREQ:STOP 510.0MHZ")
ret = dev:write(":FREQ:STAR 490.0MHZ")
ret = dev:write("DISP:WIND:TRAC:Y:RLEV 0.00")
ret = dev:write("TRACE1:MODE MAXH")
ret = dev:write("SENS:AVER:COUN 10")
ret = dev:write(":INIT")


--print (ret)
--ret = rigol:write(":FREQ:STAR 400.0MHZ")
--ret = rigol:write(":FREQ:STOP 900.0MHZ")
--ret = rigol:write(":INIT:IMM")
ret = rigol:write(":POW:GAIN 1")
ret = rigol:write("UNIT:POW DBM")
ret = rigol:write("SENS:POW:ATT 10.00 DB")

ret = rigol:write(":BAND:RES 3KHZ")
ret = rigol:write(":BAND:VID 3MHZ")
ret = rigol:write("SENS:SWE:TIME 8MS")
ret = rigol:write(":INIT:CONT OFF")
ret = rigol:write("DISP:WIND:TRAC:Y:RLEV 0.00")
ret = rigol:write("TRACE1:MODE MAXH")


--ret = rigol:write("*IDN?\n")
--ret = rigol:read(256)
--print (ret.ret)
--print (ret.count[0])
--print (ret.buf[1])
--id=ffi.string(ret.buf,ret.count[0])
--print(id)
ret = rigol:write(":SWE:COUN 1")
ret = rigol:write(":INIT:CONT OFF")
ret = rigol:write(":INIT")
ret = rigol:write(":CALC:MARK1:MAX:MAX")
ret = rigol:write(":CALC:MARK:Y?")
ret = rigol:read(256)
id=ffi.string(ret.buf,ret.count[0])
print(id)
--print(ret.ret)
rigol:close()

function 

if (freq>=1.0e9)
		{
			if (DoInstFn(inst, INS_SA_BW_RES,  NAN, 0,INS_SA_BW_1MZ)) goto done;
			if (DoInstFn(inst, INS_SA_BW_VIDEO,  NAN, 0,INS_SA_BW_1MZ)) goto done;
			if (DoInstFn(inst, INS_SA_SWEEP_TIME, NAN,7,1012)) goto done;
			span = 2.0e6;
			current_freq = 	freq;
		}
		else if (freq>=10.0e6)
		{
			if (DoInstFn(inst, INS_SA_BW_RES,  NAN, 0,INS_SA_BW_100KZ)) goto done;
			if (DoInstFn(inst, INS_SA_BW_VIDEO,  NAN, 0,INS_SA_BW_100KZ)) goto done;
			if (DoInstFn(inst, INS_SA_SWEEP_TIME, NAN,7,1012)) goto done;
			span = 1.0e6;
			current_freq = 	freq;
		}
		else if (freq>=100.0e3)
		{
			if (DoInstFn(inst, INS_SA_BW_RES,  NAN, 0,INS_SA_BW_10KZ)) goto done;
			if (DoInstFn(inst, INS_SA_BW_VIDEO,  NAN, 0,INS_SA_BW_10KZ)) goto done;
			if (DoInstFn(inst, INS_SA_SWEEP_TIME, NAN,7,1012)) goto done;
			span = 100.0e3;
			current_freq = 	freq;
		}
		else if (freq>=10.0e3)
		{
			if (DoInstFn(inst, INS_SA_BW_RES, NAN,0,INS_SA_BW_3KZ)) goto done;
			if (DoInstFn(inst, INS_SA_BW_VIDEO,  NAN, 0,INS_SA_BW_3KZ)) goto done;
			if (DoInstFn(inst, INS_SA_SWEEP_TIME, NAN,7,1012)) goto done;
			span = 5.0e3;
			current_freq = freq;
		}
		else if (freq>=1.0e3)
		{
			if (DoInstFn(inst, INS_SA_BW_RES, NAN,0,INS_SA_BW_100HZ)) goto done;
			if (DoInstFn(inst, INS_SA_BW_VIDEO,  NAN, 0,INS_SA_BW_100HZ)) goto done;
			if (DoInstFn(inst, INS_SA_SWEEP_TIME, NAN,7,1012)) goto done;
			span = 500.0;
			current_freq = freq;
		}
		else if (freq>=100.0)
		{
			if (DoInstFn(inst, INS_SA_BW_RES, NAN,0,INS_SA_BW_10HZ)) goto done;
			if (DoInstFn(inst, INS_SA_BW_VIDEO,  NAN, 0,INS_SA_BW_10HZ)) goto done;
			if (DoInstFn(inst, INS_SA_SWEEP_TIME, NAN,7,1012)) goto done;
			span = 50.0;
			current_freq = freq;
		}
		else
		{

			if (DoInstFn(inst, INS_SA_BW_RES,	NAN, 0,INS_SA_BW_10HZ)) goto done;
			if (DoInstFn(inst, INS_SA_BW_VIDEO, NAN, 0,INS_SA_BW_10HZ)) goto done;
			
			span = 50.0;
			
		}
		
			--[[
	for x in xrange(start,stop,steps) do
		print (x)
	end
	--]]
	--local t = table.concat(map(add_member, freqs),",")
	--print (t)