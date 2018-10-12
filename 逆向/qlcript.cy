(function(exports) {
	var invalidParamStr = 'Invalid parameter';
	var missingParamStr = 'Missing parameter';

	// app id
	QLAppId = [NSBundle mainBundle].bundleIdentifier;

	// mainBundlePath
	QLAppPath = [NSBundle mainBundle].bundlePath;

	// document path
	QLDocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

	// caches path
	QLCachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]; 

	// 加载系统动态库
	QLLoadFramework = function(name) {
		var head = "/System/Library/";
		var foot = "Frameworks/" + name + ".framework";
		var bundle = [NSBundle bundleWithPath:head + foot] || [NSBundle bundleWithPath:head + "Private" + foot];
  		[bundle load];
  		return bundle;
	};

	// keyWindow
	QLKeyWin = function() {
		return UIApp.keyWindow;
	};

	// 根控制器
	QLRootVc =  function() {
		return UIApp.keyWindow.rootViewController;
	};

	// 找到显示在最前面的控制器
	var _QLFrontVc = function(vc) {
		if (vc.presentedViewController) {
        	return _QLFrontVc(vc.presentedViewController);
	    }else if ([vc isKindOfClass:[UITabBarController class]]) {
	        return _QLFrontVc(vc.selectedViewController);
	    } else if ([vc isKindOfClass:[UINavigationController class]]) {
	        return _QLFrontVc(vc.visibleViewController);
	    } else {
	    	var count = vc.childViewControllers.count;
    		for (var i = count - 1; i >= 0; i--) {
    			var childVc = vc.childViewControllers[i];
    			if (childVc && childVc.view.window) {
    				vc = _QLFrontVc(childVc);
    				break;
    			}
    		}
	        return vc;
    	}
	};

	QLFrontVc =  function() {
		return _QLFrontVc(UIApp.keyWindow.rootViewController);
	};

	// CG函数
	QLPointMake = function(x, y) { 
		return {0 : x, 1 : y}; 
	};

	QLSizeMake = function(w, h) { 
		return {0 : w, 1 : h}; 
	};

	QLRectMake = function(x, y, w, h) { 
		return {0 : QLPointMake(x, y), 1 : QLSizeMake(w, h)}; 
	};

	// 递归打印controller的层级结构
	QLChildVcs = function(vc) {
		if (![vc isKindOfClass:[UIViewController class]]) throw new Error(invalidParamStr);
		return [vc _printHierarchy].toString();
	};

	// 递归打印view的层级结构
	QLSubviews = function(view) { 
		if (![view isKindOfClass:[UIView class]]) throw new Error(invalidParamStr);
		return view.recursiveDescription().toString(); 
	};

	// 判断是否为字符串 "str" @"str"
	QLIsString = function(str) {
		return typeof str == 'string' || str instanceof String;
	};

	// 判断是否为数组 []、@[]
	QLIsArray = function(arr) {
		return arr instanceof Array;
	};

	// 判断是否为数字 666 @666
	QLIsNumber = function(num) {
		return typeof num == 'number' || num instanceof Number;
	};

	var _QLClass = function(className) {
		if (!className) throw new Error(missingParamStr);
		if (QLIsString(className)) {
			return NSClassFromString(className);
		} 
		if (!className) throw new Error(invalidParamStr);
		// 对象或者类
		return className.class();
	};

	// 打印所有的子类
	QLSubclasses = function(className, reg) {
		className = _QLClass(className);

		return [c for each (c in ObjectiveC.classes) 
		if (c != className 
			&& class_getSuperclass(c) 
			&& [c isSubclassOfClass:className] 
			&& (!reg || reg.test(c)))
			];
	};

	// 打印所有的方法
	var _QLGetMethods = function(className, reg, clazz) {
		className = _QLClass(className);

		var count = new new Type('I');
		var classObj = clazz ? className.constructor : className;
		var methodList = class_copyMethodList(classObj, count);
		var methodsArray = [];
		var methodNamesArray = [];
		for(var i = 0; i < *count; i++) {
			var method = methodList[i];
			var selector = method_getName(method);
			var name = sel_getName(selector);
			if (reg && !reg.test(name)) continue;
			methodsArray.push({
				selector : selector, 
				type : method_getTypeEncoding(method)
			});
			methodNamesArray.push(name);
		}
		free(methodList);
		return [methodsArray, methodNamesArray];
	};

	var _QLMethods = function(className, reg, clazz) {
		return _QLGetMethods(className, reg, clazz)[0];
	};

	// 打印所有的方法名字
	var _QLMethodNames = function(className, reg, clazz) {
		return _QLGetMethods(className, reg, clazz)[1];
	};

	// 打印所有的对象方法
	QLInstanceMethods = function(className, reg) {
		return _QLMethods(className, reg);
	};

	// 打印所有的对象方法名字
	QLInstanceMethodNames = function(className, reg) {
		return _QLMethodNames(className, reg);
	};

	// 打印所有的类方法
	QLClassMethods = function(className, reg) {
		return _QLMethods(className, reg, true);
	};

	// 打印所有的类方法名字
	QLClassMethodNames = function(className, reg) {
		return _QLMethodNames(className, reg, true);
	};

	// 打印所有的成员变量
	QLIvars = function(obj, reg){ 
		if (!obj) throw new Error(missingParamStr);
		var x = {}; 
		for(var i in *obj) { 
			try { 
				var value = (*obj)[i];
				if (reg && !reg.test(i) && !reg.test(value)) continue;
				x[i] = value; 
			} catch(e){} 
		} 
		return x; 
	};

	// 打印所有的成员变量名字
	QLIvarNames = function(obj, reg) {
		if (!obj) throw new Error(missingParamStr);
		var array = [];
		for(var name in *obj) { 
			if (reg && !reg.test(name)) continue;
			array.push(name);
		}
		return array;
	};
})(exports);