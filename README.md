# Honoka Project

Hello everyone! 👋 Welcome to the **Honoka Project**.

Honoka is a personal project that focuses on developing a specialized client system — the **Honoka Client Project**. This system is designed to help store history, track activities, and manage reading and watching habits — all in one place.

---

## Must Read

### 📌 What Is It For?

You might be wondering: *"What does this actually do?"*

Simply put, Honoka is a personal backend system created to log and track your daily activities — like reading books, watching shows, or any other activity you want to record privately and efficiently.

---

### ⚠️ Important Notice

> **Before installing or using this system on your personal server, you are required to read and agree to our terms and policies.**
>
> Please review the following documents:
>
> - [DISCLAIMER.md](./DISCLAIMER.md)
> - [LICENSE.md](./LICENSE.md)
>
> By installing and using this application or system on your personal device, **you are acknowledging and agreeing to follow our rules and policies**.
>
> Any actions or consequences that occur after installation are entirely beyond our control and responsibility.

---

### 📄 Licensing & Usage Terms

> 🔒 **This is not an open-source project.**

> ✅ You are allowed to **store this code privately** and **self-host it for personal, non-commercial use only**.

> 🚫 You are **not allowed to redistribute, modify for public release, or use this project for any commercial purposes** without explicit permission from the creator.

---

If you're interested in exploring further or trying it out for your own personal use — feel free to browse the repository.  
Thanks for stopping by! 💜

## Configuration



## Extensions

Provided extension from miyuna is

### MyAnimeList (Track record integration have)

```env
# MyAnimeList API credentials
# You can obtain these by creating an application on the MyAnimeList developer portal
MAL_CLIENT_ID="paste client id here" # Get from MyAnimeList website
MAL_CLIENT_SECRET="paste client server here" # Get from MyAnimeList website
MAL_REDIRECT_URI="/callback"
MAL_PKCE_CODE_VERIFIER="create random string min 45 digit and max 100 digit"
```

### Anilist (Track record integration have)

```env
# Anilist API credentials
# You can obtain these by creating an application on the Anilist developer portal
ANILIST_CLIENT_ID="paste client id here" # Get from AniList website
ANILIST_CLIENT_SECRET="paste client server here" # Get from AniList website
ANILIST_REDIRECT_ENDPOINT="/callback"