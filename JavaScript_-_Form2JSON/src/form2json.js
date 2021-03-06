/**
 * @author Maxim Vasiliev
 * Date: 09.09.2010
 * Time: 19:02:33
 */

(function()
{

	/**
	 * Returns form values represented as Javascript object
	 * "name" attribute defines structure of resulting object
	 *
	 * @param rootNode {DOMElement} root form element
	 */
	window.form2json = function(rootNode)
	{
		var formValues = getFormValues(rootNode);
		var result = {};
		var arrays = {};

		for (var i = 0; i < formValues.length; i++)
		{
			var value = formValues[i].value;
			if (value === '') continue;

			var name = formValues[i].name;
			var nameParts = name.split('.');

			var currResult = result;

			for (var j = 0; j < nameParts.length; j++)
			{
				var namePart = nameParts[j];

				if (namePart.indexOf('[]') > -1 && j == nameParts.length - 1)
				{
					var arrName = namePart.substr(0, namePart.indexOf('['));

					if (!currResult[arrName]) currResult[arrName] = [];
					currResult[arrName].push( value );
				}
				else if (namePart.indexOf('[') > -1)
				{
					var arrName = namePart.substr(0, namePart.indexOf('['));
					var arrIdx = namePart.replace(/^[a-z]+\[|\]$/gi, '');

					/*
					 Т.к. индексы у нас могут не быть от 0 и с шагом 1,
					 то напрямую в массив запихивать данные нельзя.
					 Значит, делаем хеш, в котором по значению индекса в arrIdx
					 храним ссылку на соответствующий элемент массива
					 */

					if (!arrays[arrName]) arrays[arrName] = {};
					if (!currResult[arrName]) currResult[arrName] = [];

					if (j == nameParts.length - 1)
					{
						currResult[arrName].push(value);
					}
					else if (!arrays[arrName][arrIdx])
					{
						currResult[arrName].push({});
						arrays[arrName][arrIdx] = currResult[arrName][currResult[arrName].length - 1];
					}

					currResult = arrays[arrName][arrIdx];
				}
				else
				{
					if (j < nameParts.length - 1) /* Not the last part of name - means object */
					{
						if (!currResult[namePart]) currResult[namePart] = {};
						currResult = currResult[namePart];
					}
					else
					{
						currResult[namePart] = value;
					}
				}
			}
		}

		return result;
	}

	function getFormValues(rootNode)
	{
		var result = [];
		var currentNode = rootNode.firstChild;

		while (currentNode)
		{
			if (currentNode.nodeName.isIn('INPUT', 'SELECT', 'TEXTAREA', 'FIELDSET'))
			{
				result.push({ name: currentNode.name, value: getFieldValue(currentNode)});
			}
			else
			{
				var subresult = getFormValues(currentNode);
				result = result.concat(subresult);
			}

			currentNode = currentNode.nextSibling;
		}

		return result;
	}

	function getFieldValue(fieldNode)
	{
		if (fieldNode.nodeName == 'INPUT')
		{
			if (fieldNode.type.toLowerCase() == 'radio' || fieldNode.type.toLowerCase() == 'checkbox')
			{
				if (fieldNode.checked)
				{
					return fieldNode.value;
				}
			}
			else
			{
				if (!fieldNode.type.toLowerCase().isIn('button', 'reset', 'submit', 'image'))
				{
					return fieldNode.value;
				}
			}
		}
		else
		{
			if (fieldNode.nodeName == 'TEXTAREA')
			{
				return fieldNode.innerHTML;
			}
			else
			{
				if (fieldNode.nodeName == 'SELECT')
				{
					return getSelectedOptionValue(fieldNode);
				}
			}
		}

		return '';
	}

	String.prototype.isIn = function()
	{
		for (var i = 0; i < arguments.length; i++)
		{
			if (this == arguments[i])
			{
				return true;
			}
		}

		return false;
	};

	function getSelectedOptionValue(selectNode, multiple)
	{
		var option = selectNode.firstChild;

		multiple = (multiple == null) ? selectNode.multiple : multiple;

		var result = multiple ? [] : '';

		while (option != null)
		{
			while (option != null && (option.nodeName != 'OPTION' && option.nodeName != 'OPTGROUP'))
			{
				option = option.nextSibling;
			}
			
			if (option == null) continue;

			if (option.nodeName == 'OPTION' && option.selected)
			{
				if (multiple)
					result.push(option.value)
				else
					return option.value;
			}
			else
			{
				if (option.nodeName == 'OPTGROUP')
				{
					var optgroupValue = getSelectedOptionValue(option, multiple);
					if (optgroupValue != '')
					{
						if (multiple)
						{
							for(var i = 0; i < optgroupValue.length; i++) result.push(optgroupValue[i]);
						}
						else return optgroupValue;
					}
				}
			}

			option = option.nextSibling;
		}

		return result;
	}

})();