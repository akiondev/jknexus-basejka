
class timing_c
{
private:
#if defined(_WIN32)
	__int64	start;
	__int64	end;
#else
	unsigned long long start;
	unsigned long long end;
#endif

	int		reset;
public:
	timing_c(void)
	{
	}
	void Start()
	{
#if defined(_WIN32)
		const __int64 *s = &start;
		__asm
		{
			push eax
			push ebx
			push edx

			rdtsc
			mov ebx, s
			mov	[ebx], eax
			mov [ebx + 4], edx

			pop edx
			pop ebx
			pop eax
		}
#else
		unsigned int lo, hi;
		__asm__ __volatile__("rdtsc" : "=a"(lo), "=d"(hi));
		start = ((unsigned long long)hi << 32) | lo;
#endif
	}
	int End()
	{
#if defined(_WIN32)
		const __int64 *e = &end;
		__int64	time;
		__asm
		{
			push eax
			push ebx
			push edx

			rdtsc
			mov ebx, e
			mov	[ebx], eax
			mov [ebx + 4], edx

			pop edx
			pop ebx
			pop eax
		}
		return((int)(end - start));
#else
		unsigned int lo, hi;
		unsigned long long time;
		__asm__ __volatile__("rdtsc" : "=a"(lo), "=d"(hi));
		end = ((unsigned long long)hi << 32) | lo;
		time = end - start;
		if (time < 0)
		{
			time = 0;
		}
		return((int)time);
#endif
	}
};
// end