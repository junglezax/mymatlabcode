function label = code2label(labelLevel, code)
	if ~exist('code', 'var')
		code = -1; % for num classes
	end

	levels{1} = 1:5;
	
	levels{2} = [11, 12, 13, 21, 22, 23, 24, 31, 32, 33, 34, 40, 51, 52];
	
	levels{3} = [111, 112, 113, 114, 115, 116, 117, 118, 121, 122, 123, 124, 125, 126, 131, 132, 133, 211, 212, 213, 214, 215, 216, 217, 221, 222, 223, 224, 225, 231, 232, 241, 242, 243, 244, 245, 246, 247, 311, 312, 313, 314, 315, 316, 321, 322, 323, 324, 331, 332, 333, 334, 335, 336, 337, 341, 342, 401, 402, 403, 404, 405, 406, 407, 408, 511, 512, 513, 514, 521, 522, 523, 524];
	
	levels{4} = [1111, 1112, 1113, 1114, 1121, 1122, 1123, 1124, 1131, 1132, 1133, 1134, 1141, 1142, 1143, 1144, 1151, 1152, 1153, 1154, 1161, 1162, 1163, 1164, 1171, 1172, 1173, 1174, 1181, 1182, 1183, 1184, 1211, 1212, 1213, 1214, 1221, 1222, 1223, 1224, 1231, 1232, 1233, 1234, 1241, 1242, 1243, 1244, 1251, 1252, 1253, 1254, 1261, 1262, 1263, 1264, 1311, 1312, 1313, 1314, 1321, 1322, 1323, 1324, 1331, 1332, 1333, 1334, 2111, 2112, 2113, 2114, 2121, 2122, 2123, 2124, 2131, 2132, 2133, 2134, 2141, 2142, 2143, 2144, 2151, 2152, 2153, 2154, 2161, 2162, 2163, 2164, 2171, 2172, 2173, 2174, 2211, 2212, 2213, 2214, 2221, 2222, 2223, 2224, 2231, 2232, 2233, 2234, 2241, 2242, 2243, 2244, 2251, 2252, 2253, 2254, 2311, 2312, 2313, 2314, 2321, 2322, 2323, 2324, 2411, 2412, 2413, 2414, 2421, 2422, 2423, 2424, 2431, 2432, 2433, 2434, 2441, 2442, 2443, 2444, 2451, 2452, 2453, 2454, 2461, 2462, 2463, 2464, 2471, 2472, 2473, 2474, 3111, 3112, 3113, 3114, 3121, 3122, 3123, 3124, 3131, 3132, 3133, 3134, 3141, 3142, 3143, 3144, 3151, 3152, 3153, 3154, 3161, 3162, 3163, 3164, 3211, 3212, 3213, 3214, 3221, 3222, 3223, 3224, 3231, 3232, 3233, 3234, 3241, 3242, 3243, 3244, 3311, 3312, 3313, 3314, 3321, 3322, 3323, 3324, 3331, 3332, 3333, 3334, 3341, 3342, 3343, 3344, 3351, 3352, 3353, 3354, 3361, 3362, 3363, 3364, 3371, 3372, 3373, 3374, 3411, 3412, 3413, 3414, 3421, 3422, 3423, 3424, 4011, 4012, 4013, 4014, 4021, 4022, 4023, 4024, 4031, 4032, 4033, 4034, 4041, 4042, 4043, 4044, 4051, 4052, 4053, 4054, 4061, 4062, 4063, 4064, 4071, 4072, 4073, 4074, 4081, 4082, 4083, 4084];

	if code == -1
		label = numel(levels{labelLevel}); % num classes
		return
	end

	label = find(levels{labelLevel} == str2num(code(1:labelLevel)));
end

function genLabel4(level3)
	for i = 1:numel(level3)
		for j = 1:4
			disp(level3(i) * 10 + j)
		end
	end
end
