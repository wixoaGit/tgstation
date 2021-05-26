#define fetchElement(L, i) (associative) ? L[L[i]] : L[i]

#define MIN_MERGE 32

#define MIN_GALLOP 7

GLOBAL_DATUM_INIT(sortInstance, /datum/sortInstance, new())
/datum/sortInstance
	var/list/L

	var/cmp = /proc/cmp_numeric_asc

	var/associative = 0

	var/minGallop = MIN_GALLOP

	var/list/runBases = list()
	var/list/runLens = list()

	proc/timSort(start, end)
		runBases.Cut()
		runLens.Cut()

		var/remaining = end - start

		if(remaining < MIN_MERGE)
			var/initRunLen = countRunAndMakeAscending(start, end)
			binarySort(start, end, start+initRunLen)
			return

		var/minRun = minRunLength(remaining)

		do
			var/runLen = countRunAndMakeAscending(start, end)

			if(runLen < minRun)
				var/force = (remaining <= minRun) ? remaining : minRun

				binarySort(start, start+force, start+runLen)
				runLen = force

			runBases.Add(start)
			runLens.Add(runLen)

			mergeCollapse()

			start += runLen
			remaining -= runLen

		while(remaining > 0)

		mergeForceCollapse();

		minGallop = MIN_GALLOP

		return L

	proc/binarySort(lo, hi, start)
		if(start <= lo)
			start = lo + 1

		//for(,start < hi, ++start)
		for(start,start < hi, ++start)//not_actual
			var/pivot = fetchElement(L,start)

			var/left = lo
			var/right = start

			while(left < right)
				var/mid = (left + right) >> 1
				if(call(cmp)(fetchElement(L,mid), pivot) > 0)
					right = mid
				else
					left = mid+1

			moveElement(L, start, left)
	
	proc/countRunAndMakeAscending(lo, hi)
		var/runHi = lo + 1
		if(runHi >= hi)
			return 1

		var/last = fetchElement(L,lo)
		var/current = fetchElement(L,runHi++)

		if(call(cmp)(current, last) < 0)
			while(runHi < hi)
				last = current
				current = fetchElement(L,runHi)
				if(call(cmp)(current, last) >= 0)
					break
				++runHi
			reverseRange(L, lo, runHi)
		else
			while(runHi < hi)
				last = current
				current = fetchElement(L,runHi)
				if(call(cmp)(current, last) < 0)
					break
				++runHi

		return runHi - lo
	
	proc/minRunLength(n)
		var/r = 0
		while(n >= MIN_MERGE)
			r |= (n & 1)
			n >>= 1
		return n + r
	
	proc/mergeCollapse()
		while(runBases.len >= 2)
			var/n = runBases.len - 1
			if(n > 1 && runLens[n-1] <= runLens[n] + runLens[n+1])
				if(runLens[n-1] < runLens[n+1])
					--n
				mergeAt(n)
			else if(runLens[n] <= runLens[n+1])
				mergeAt(n)
			else
				break
	
	proc/mergeForceCollapse()
		while(runBases.len >= 2)
			var/n = runBases.len - 1
			if(n > 1 && runLens[n-1] < runLens[n+1])
				--n
			mergeAt(n)
	
	proc/mergeAt(i)
		var/base1 = runBases[i]
		var/base2 = runBases[i+1]
		var/len1 = runLens[i]
		var/len2 = runLens[i+1]

		runLens[i] += runLens[i+1]
		runLens.Cut(i+1, i+2)
		runBases.Cut(i+1, i+2)

		var/k = gallopRight(fetchElement(L,base2), base1, len1, 0)
		base1 += k
		len1 -= k
		if(len1 == 0)
			return

		len2 = gallopLeft(fetchElement(L,base1 + len1 - 1), base2, len2, len2-1)
		if(len2 == 0)
			return

		if(len1 <= len2)
			mergeLo(base1, len1, base2, len2)
		else
			mergeHi(base1, len1, base2, len2)
	
	proc/gallopLeft(key, base, len, hint)
		var/lastOffset = 0
		var/offset = 1
		if(call(cmp)(key, fetchElement(L,base+hint)) > 0)
			var/maxOffset = len - hint
			while(offset < maxOffset && call(cmp)(key, fetchElement(L,base+hint+offset)) > 0)
				lastOffset = offset
				offset = (offset << 1) + 1

			if(offset > maxOffset)
				offset = maxOffset

			lastOffset += hint
			offset += hint

		else
			var/maxOffset = hint + 1
			while(offset < maxOffset && call(cmp)(key, fetchElement(L,base+hint-offset)) <= 0)
				lastOffset = offset
				offset = (offset << 1) + 1

			if(offset > maxOffset)
				offset = maxOffset

			var/temp = lastOffset
			lastOffset = hint - offset
			offset = hint - temp

		++lastOffset
		while(lastOffset < offset)
			var/m = lastOffset + ((offset - lastOffset) >> 1)

			if(call(cmp)(key, fetchElement(L,base+m)) > 0)
				lastOffset = m + 1
			else
				offset = m

		return offset

	proc/gallopRight(key, base, len, hint)
		var/offset = 1
		var/lastOffset = 0
		if(call(cmp)(key, fetchElement(L,base+hint)) < 0)
			var/maxOffset = hint + 1
			while(offset < maxOffset && call(cmp)(key, fetchElement(L,base+hint-offset)) < 0)
				lastOffset = offset
				offset = (offset << 1) + 1

			if(offset > maxOffset)
				offset = maxOffset

			var/temp = lastOffset
			lastOffset = hint - offset
			offset = hint - temp

		else
			var/maxOffset = len - hint
			while(offset < maxOffset && call(cmp)(key, fetchElement(L,base+hint+offset)) >= 0)
				lastOffset = offset
				offset = (offset << 1) + 1

			if(offset > maxOffset)
				offset = maxOffset

			lastOffset += hint
			offset += hint

		++lastOffset
		while(lastOffset < offset)
			var/m = lastOffset + ((offset - lastOffset) >> 1)

			if(call(cmp)(key, fetchElement(L,base+m)) < 0)
				offset = m
			else
				lastOffset = m + 1

		return offset

	proc/mergeLo(base1, len1, base2, len2)
		var/cursor1 = base1
		var/cursor2 = base2

		if(len2 == 1)
			moveElement(L, cursor2, cursor1)
			return

		if(len1 == 1)
			moveElement(L, cursor1, cursor2+len2)
			return


		moveElement(L, cursor2++, cursor1++)
		--len2

		/*outer:
			while(1)
				var/count1 = 0
				var/count2 = 0

				do
					if(call(cmp)(fetchElement(L,cursor2), fetchElement(L,cursor1)) < 0)
						moveElement(L, cursor2++, cursor1++)
						--len2

						++count2
						count1 = 0

						if(len2 == 0)
							break outer
					else
						++cursor1

						++count1
						count2 = 0

						if(--len1 == 1)
							break outer

				while((count1 | count2) < minGallop)

				do

					count1 = gallopRight(fetchElement(L,cursor2), cursor1, len1, 0)
					if(count1)
						cursor1 += count1
						len1 -= count1

						if(len1 <= 1)
							break outer

					moveElement(L, cursor2, cursor1)
					++cursor2
					++cursor1
					if(--len2 == 0)
						break outer

					count2 = gallopLeft(fetchElement(L,cursor1), cursor2, len2, 0)
					if(count2)
						moveRange(L, cursor2, cursor1, count2)

						cursor2 += count2
						cursor1 += count2
						len2 -= count2

						if(len2 == 0)
							break outer

					++cursor1
					if(--len1 == 1)
						break outer

					--minGallop

				while((count1|count2) > MIN_GALLOP)

				if(minGallop < 0)
					minGallop = 0
				minGallop += 2;*/
		//not_actual
		var/break_outer = FALSE
		while(1)
			var/count1 = 0
			var/count2 = 0

			do
				if(call(cmp)(fetchElement(L,cursor2), fetchElement(L,cursor1)) < 0)
					moveElement(L, cursor2++, cursor1++)
					--len2

					++count2
					count1 = 0

					if(len2 == 0)
						break_outer = TRUE
						break
				else
					++cursor1

					++count1
					count2 = 0

					if(--len1 == 1)
						break_outer = TRUE
						break
			while((count1 | count2) < minGallop)
			if (break_outer) break

			do
				count1 = gallopRight(fetchElement(L,cursor2), cursor1, len1, 0)
				if(count1)
					cursor1 += count1
					len1 -= count1

					if(len1 <= 1)
						break_outer = TRUE
						break

				moveElement(L, cursor2, cursor1)
				++cursor2
				++cursor1
				if(--len2 == 0)
					break_outer = TRUE
					break

				count2 = gallopLeft(fetchElement(L,cursor1), cursor2, len2, 0)
				if(count2)
					moveRange(L, cursor2, cursor1, count2)

					cursor2 += count2
					cursor1 += count2
					len2 -= count2

					if(len2 == 0)
						break_outer = TRUE
						break

				++cursor1
				if(--len1 == 1)
					break_outer = TRUE
					break

				--minGallop
			while((count1|count2) > MIN_GALLOP)
			if (break_outer) break

			if(minGallop < 0)
				minGallop = 0
			minGallop += 2;

		if(len1 == 1)
			moveElement(L, cursor1, cursor2+len2)


	proc/mergeHi(base1, len1, base2, len2)
		var/cursor1 = base1 + len1 - 1
		var/cursor2 = base2 + len2 - 1

		if(len2 == 1)
			moveElement(L, base2, base1)
			return

		if(len1 == 1)
			moveElement(L, base1, cursor2+1)
			return

		moveElement(L, cursor1--, cursor2-- + 1)
		--len1

		/*outer:
			while(1)
				var/count1 = 0
				var/count2 = 0

				do
					if(call(cmp)(fetchElement(L,cursor2), fetchElement(L,cursor1)) < 0)
						moveElement(L, cursor1--, cursor2-- + 1)
						--len1

						++count1
						count2 = 0

						if(len1 == 0)
							break outer
					else
						--cursor2
						--len2

						++count2
						count1 = 0

						if(len2 == 1)
							break outer
				while((count1 | count2) < minGallop)

				do
					count1 = len1 - gallopRight(fetchElement(L,cursor2), base1, len1, len1-1)
					if(count1)
						cursor1 -= count1

						moveRange(L, cursor1+1, cursor2+1, count1)

						cursor2 -= count1
						len1 -= count1

						if(len1 == 0)
							break outer

					--cursor2

					if(--len2 == 1)
						break outer

					count2 = len2 - gallopLeft(fetchElement(L,cursor1), cursor1+1, len2, len2-1)
					if(count2)
						cursor2 -= count2
						len2 -= count2

						if(len2 <= 1)
							break outer

					moveElement(L, cursor1--, cursor2-- + 1)
					--len1

					if(len1 == 0)
						break outer

					--minGallop
				while((count1|count2) > MIN_GALLOP)

				if(minGallop < 0)
					minGallop = 0
				minGallop += 2*/
		//not_actual
		var/break_outer = FALSE
		while(1)
			var/count1 = 0
			var/count2 = 0

			do
				if(call(cmp)(fetchElement(L,cursor2), fetchElement(L,cursor1)) < 0)
					moveElement(L, cursor1--, cursor2-- + 1)
					--len1

					++count1
					count2 = 0

					if(len1 == 0)
						break_outer = TRUE
						break
				else
					--cursor2
					--len2

					++count2
					count1 = 0

					if(len2 == 1)
						break_outer = TRUE
						break
			while((count1 | count2) < minGallop)
			if (break_outer) break

			do
				count1 = len1 - gallopRight(fetchElement(L,cursor2), base1, len1, len1-1)
				if(count1)
					cursor1 -= count1

					moveRange(L, cursor1+1, cursor2+1, count1)

					cursor2 -= count1
					len1 -= count1

					if(len1 == 0)
						break_outer = TRUE
						break

				--cursor2

				if(--len2 == 1)
					break_outer = TRUE
					break

				count2 = len2 - gallopLeft(fetchElement(L,cursor1), cursor1+1, len2, len2-1)
				if(count2)
					cursor2 -= count2
					len2 -= count2

					if(len2 <= 1)
						break_outer = TRUE
						break

				moveElement(L, cursor1--, cursor2-- + 1)
				--len1

				if(len1 == 0)
					break_outer = TRUE
					break

				--minGallop
			while((count1|count2) > MIN_GALLOP)
			if (break_outer) break

			if(minGallop < 0)
				minGallop = 0
			minGallop += 2

		if(len2 == 1)
			cursor1 -= len1
			moveRange(L, cursor1+1, cursor2+1, len1)