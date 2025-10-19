#!/usr/bin/env python3
"""
Expand Spiritual Themes Script for UR4MORE Wellness App
Adds spiritual warfare, work-inspired, and body/temple themed KJV verses
"""

import json

class SpiritualThemesExpansion:
    def __init__(self):
        self.new_verses = self.create_spiritual_warfare_verses()
        self.new_verses.update(self.create_work_inspired_verses())
        self.new_verses.update(self.create_body_temple_verses())
        
    def create_spiritual_warfare_verses(self):
        """Create spiritual warfare themed verses"""
        
        spiritual_warfare_verses = {
            # Spiritual Warfare & Armor of God
            "Ephesians 6:10": "Finally, my brethren, be strong in the Lord, and in the power of his might.",
            "Ephesians 6:11": "Put on the whole armour of God, that ye may be able to stand against the wiles of the devil.",
            "Ephesians 6:12": "For we wrestle not against flesh and blood, but against principalities, against powers, against the rulers of the darkness of this world, against spiritual wickedness in high places.",
            "Ephesians 6:13": "Wherefore take unto you the whole armour of God, that ye may be able to withstand in the evil day, and having done all, to stand.",
            "Ephesians 6:14": "Stand therefore, having your loins girt about with truth, and having on the breastplate of righteousness.",
            "Ephesians 6:15": "And your feet shod with the preparation of the gospel of peace.",
            "Ephesians 6:16": "Above all, taking the shield of faith, wherewith ye shall be able to quench all the fiery darts of the wicked.",
            "Ephesians 6:17": "And take the helmet of salvation, and the sword of the Spirit, which is the word of God.",
            "Ephesians 6:18": "Praying always with all prayer and supplication in the Spirit, and watching thereunto with all perseverance and supplication for all saints.",
            
            # Victory & Overcoming
            "1 John 4:4": "Ye are of God, little children, and have overcome them: because greater is he that is in you, than he that is in the world.",
            "Romans 8:37": "Nay, in all these things we are more than conquerors through him that loved us.",
            "1 Corinthians 15:57": "But thanks be to God, which giveth us the victory through our Lord Jesus Christ.",
            "2 Corinthians 10:4": "For the weapons of our warfare are not carnal, but mighty through God to the pulling down of strong holds.",
            "2 Corinthians 10:5": "Casting down imaginations, and every high thing that exalteth itself against the knowledge of God, and bringing into captivity every thought to the obedience of Christ.",
            "1 John 5:4": "For whatsoever is born of God overcometh the world: and this is the victory that overcometh the world, even our faith.",
            "Revelation 12:11": "And they overcame him by the blood of the Lamb, and by the word of their testimony; and they loved not their lives unto the death.",
            "James 4:7": "Submit yourselves therefore to God. Resist the devil, and he will flee from you.",
            "1 Peter 5:8": "Be sober, be vigilant; because your adversary the devil, as a roaring lion, walketh about, seeking whom he may devour.",
            "1 Peter 5:9": "Whom resist stedfast in the faith, knowing that the same afflictions are accomplished in your brethren that are in the world.",
            
            # Spiritual Authority & Power
            "Luke 10:19": "Behold, I give unto you power to tread on serpents and scorpions, and over all the power of the enemy: and nothing shall by any means hurt you.",
            "Mark 16:17": "And these signs shall follow them that believe; In my name shall they cast out devils; they shall speak with new tongues.",
            "Matthew 16:19": "And I will give unto thee the keys of the kingdom of heaven: and whatsoever thou shalt bind on earth shall be bound in heaven: and whatsoever thou shalt loose on earth shall be loosed in heaven.",
            "Matthew 18:18": "Verily I say unto you, Whatsoever ye shall bind on earth shall be bound in heaven: and whatsoever ye shall loose on earth shall be loosed in heaven.",
            "Acts 1:8": "But ye shall receive power, after that the Holy Ghost is come upon you: and ye shall be witnesses unto me both in Jerusalem, and in all Judaea, and in Samaria, and unto the uttermost part of the earth.",
            "2 Timothy 1:7": "For God hath not given us the spirit of fear; but of power, and of love, and of a sound mind.",
            "Romans 8:15": "For ye have not received the spirit of bondage again to fear; but ye have received the Spirit of adoption, whereby we cry, Abba, Father.",
            "Galatians 5:1": "Stand fast therefore in the liberty wherewith Christ hath made us free, and be not entangled again with the yoke of bondage.",
            "John 8:36": "If the Son therefore shall make you free, ye shall be free indeed.",
            "2 Corinthians 3:17": "Now the Lord is that Spirit: and where the Spirit of the Lord is, there is liberty.",
            
            # Prayer & Fasting for Warfare
            "Matthew 17:21": "Howbeit this kind goeth not out but by prayer and fasting.",
            "Mark 9:29": "And he said unto them, This kind can come forth by nothing, but by prayer and fasting.",
            "Luke 22:40": "And when he was at the place, he said unto them, Pray that ye enter not into temptation.",
            "Matthew 26:41": "Watch and pray, that ye enter not into temptation: the spirit indeed is willing, but the flesh is weak.",
            "1 Thessalonians 5:17": "Pray without ceasing.",
            "Ephesians 6:18": "Praying always with all prayer and supplication in the Spirit, and watching thereunto with all perseverance and supplication for all saints.",
            "Colossians 4:2": "Continue in prayer, and watch in the same with thanksgiving.",
            "Luke 18:1": "And he spake a parable unto them to this end, that men ought always to pray, and not to faint.",
            "Romans 12:12": "Rejoicing in hope; patient in tribulation; continuing instant in prayer.",
            "Philippians 4:6": "Be careful for nothing; but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God.",
            
            # Spiritual Discernment & Wisdom
            "1 Corinthians 2:14": "But the natural man receiveth not the things of the Spirit of God: for they are foolishness unto him: neither can he know them, because they are spiritually discerned.",
            "Hebrews 5:14": "But strong meat belongeth to them that are of full age, even those who by reason of use have their senses exercised to discern both good and evil.",
            "1 John 4:1": "Beloved, believe not every spirit, but try the spirits whether they are of God: because many false prophets are gone out into the world.",
            "Matthew 7:15": "Beware of false prophets, which come to you in sheep's clothing, but inwardly they are ravening wolves.",
            "2 Corinthians 11:14": "And no marvel; for Satan himself is transformed into an angel of light.",
            "1 Timothy 4:1": "Now the Spirit speaketh expressly, that in the latter times some shall depart from the faith, giving heed to seducing spirits, and doctrines of devils.",
            "2 Timothy 3:1": "This know also, that in the last days perilous times shall come.",
            "2 Timothy 3:2": "For men shall be lovers of their own selves, covetous, boasters, proud, blasphemers, disobedient to parents, unthankful, unholy.",
            "2 Timothy 3:3": "Without natural affection, trucebreakers, false accusers, incontinent, fierce, despisers of those that are good.",
            "2 Timothy 3:4": "Traitors, heady, highminded, lovers of pleasures more than lovers of God.",
            
            # Deliverance & Freedom
            "Isaiah 61:1": "The Spirit of the Lord God is upon me; because the Lord hath anointed me to preach good tidings unto the meek; he hath sent me to bind up the brokenhearted, to proclaim liberty to the captives, and the opening of the prison to them that are bound.",
            "Luke 4:18": "The Spirit of the Lord is upon me, because he hath anointed me to preach the gospel to the poor; he hath sent me to heal the brokenhearted, to preach deliverance to the captives, and recovering of sight to the blind, to set at liberty them that are bruised.",
            "John 8:32": "And ye shall know the truth, and the truth shall make you free.",
            "Galatians 5:13": "For, brethren, ye have been called unto liberty; only use not liberty for an occasion to the flesh, but by love serve one another.",
            "Romans 6:18": "Being then made free from sin, ye became the servants of righteousness.",
            "Romans 6:22": "But now being made free from sin, and become servants to God, ye have your fruit unto holiness, and the end everlasting life.",
            "1 Corinthians 7:22": "For he that is called in the Lord, being a servant, is the Lord's freeman: likewise also he that is called, being free, is Christ's servant.",
            "2 Corinthians 3:17": "Now the Lord is that Spirit: and where the Spirit of the Lord is, there is liberty.",
            "Galatians 2:4": "And that because of false brethren unawares brought in, who came in privily to spy out our liberty which we have in Christ Jesus, that they might bring us into bondage.",
            "1 Peter 2:16": "As free, and not using your liberty for a cloke of maliciousness, but as the servants of God.",
        }
        
        return spiritual_warfare_verses
    
    def create_work_inspired_verses(self):
        """Create work and vocation inspired verses"""
        
        work_inspired_verses = {
            # Work Ethic & Diligence
            "Proverbs 14:23": "In all labour there is profit: but the talk of the lips tendeth only to penury.",
            "Proverbs 12:11": "He that tilleth his land shall be satisfied with bread: but he that followeth vain persons is void of understanding.",
            "Proverbs 13:4": "The soul of the sluggard desireth, and hath nothing: but the soul of the diligent shall be made fat.",
            "Proverbs 21:5": "The thoughts of the diligent tend only to plenteousness; but of every one that is hasty only to want.",
            "Proverbs 22:29": "Seest thou a man diligent in his business? he shall stand before kings; he shall not stand before mean men.",
            "Proverbs 10:4": "He becometh poor that dealeth with a slack hand: but the hand of the diligent maketh rich.",
            "Proverbs 10:5": "He that gathereth in summer is a wise son: but he that sleepeth in harvest is a son that causeth shame.",
            "Proverbs 6:6": "Go to the ant, thou sluggard; consider her ways, and be wise.",
            "Proverbs 6:7": "Which having no guide, overseer, or ruler.",
            "Proverbs 6:8": "Provideth her meat in the summer, and gathereth her food in the harvest.",
            "Proverbs 6:9": "How long wilt thou sleep, O sluggard? when wilt thou arise out of thy sleep?",
            "Proverbs 6:10": "Yet a little sleep, a little slumber, a little folding of the hands to sleep.",
            "Proverbs 6:11": "So shall thy poverty come as one that travelleth, and thy want as an armed man.",
            
            # Serving God Through Work
            "Colossians 3:23": "And whatsoever ye do, do it heartily, as to the Lord, and not unto men.",
            "Colossians 3:24": "Knowing that of the Lord ye shall receive the reward of the inheritance: for ye serve the Lord Christ.",
            "1 Corinthians 10:31": "Whether therefore ye eat, or drink, or whatsoever ye do, do all to the glory of God.",
            "Ephesians 6:7": "With good will doing service, as to the Lord, and not to men.",
            "1 Peter 4:10": "As every man hath received the gift, even so minister the same one to another, as good stewards of the manifold grace of God.",
            "Romans 12:11": "Not slothful in business; fervent in spirit; serving the Lord.",
            "Galatians 6:9": "And let us not be weary in well doing: for in due season we shall reap, if we faint not.",
            "2 Thessalonians 3:10": "For even when we were with you, this we commanded you, that if any would not work, neither should he eat.",
            "1 Timothy 5:8": "But if any provide not for his own, and specially for those of his own house, he hath denied the faith, and is worse than an infidel.",
            "Titus 2:7": "In all things showing thyself a pattern of good works: in doctrine showing uncorruptness, gravity, sincerity.",
            
            # Stewardship & Responsibility
            "Luke 16:10": "He that is faithful in that which is least is faithful also in much: and he that is unjust in the least is unjust also in much.",
            "Luke 16:11": "If therefore ye have not been faithful in the unrighteous mammon, who will commit to your trust the true riches?",
            "Luke 16:12": "And if ye have not been faithful in that which is another man's, who shall give you that which is your own?",
            "Matthew 25:21": "His lord said unto him, Well done, thou good and faithful servant: thou hast been faithful over a few things, I will make thee ruler over many things: enter thou into the joy of thy lord.",
            "Matthew 25:23": "His lord said unto him, Well done, good and faithful servant; thou hast been faithful over a few things, I will make thee ruler over many things: enter thou into the joy of thy lord.",
            "1 Corinthians 4:2": "Moreover it is required in stewards, that a man be found faithful.",
            "Proverbs 27:23": "Be thou diligent to know the state of thy flocks, and look well to thy herds.",
            "Proverbs 27:24": "For riches are not for ever: and doth the crown endure to every generation?",
            "Ecclesiastes 9:10": "Whatsoever thy hand findeth to do, do it with thy might; for there is no work, nor device, nor knowledge, nor wisdom, in the grave, whither thou goest.",
            "Proverbs 16:3": "Commit thy works unto the Lord, and thy thoughts shall be established.",
            
            # Integrity & Honesty in Work
            "Proverbs 11:1": "A false balance is abomination to the Lord: but a just weight is his delight.",
            "Proverbs 16:11": "A just weight and balance are the Lord's: all the weights of the bag are his work.",
            "Proverbs 20:10": "Divers weights, and divers measures, both of them are alike abomination to the Lord.",
            "Proverbs 20:23": "Divers weights are an abomination unto the Lord; and a false balance is not good.",
            "Leviticus 19:35": "Ye shall do no unrighteousness in judgment, in meteyard, in weight, or in measure.",
            "Leviticus 19:36": "Just balances, just weights, a just ephah, and a just hin, shall ye have: I am the Lord your God, which brought you out of the land of Egypt.",
            "Deuteronomy 25:13": "Thou shalt not have in thy bag divers weights, a great and a small.",
            "Deuteronomy 25:14": "Thou shalt not have in thine house divers measures, a great and a small.",
            "Deuteronomy 25:15": "But thou shalt have a perfect and just weight, a perfect and just measure: that thy days may be lengthened in the land which the Lord thy God giveth thee.",
            "Micah 6:11": "Shall I count them pure with the wicked balances, and with the bag of deceitful weights?",
            
            # Leadership & Excellence
            "Proverbs 29:2": "When the righteous are in authority, the people rejoice: but when the wicked beareth rule, the people mourn.",
            "Proverbs 16:12": "It is an abomination to kings to commit wickedness: for the throne is established by righteousness.",
            "Proverbs 20:28": "Mercy and truth preserve the king: and his throne is upholden by mercy.",
            "Proverbs 25:5": "Take away the wicked from before the king, and his throne shall be established in righteousness.",
            "Proverbs 29:4": "The king by judgment establisheth the land: but he that receiveth gifts overthroweth it.",
            "Proverbs 29:14": "The king that faithfully judgeth the poor, his throne shall be established for ever.",
            "1 Timothy 3:1": "This is a true saying, If a man desire the office of a bishop, he desireth a good work.",
            "1 Timothy 3:2": "A bishop then must be blameless, the husband of one wife, vigilant, sober, of good behaviour, given to hospitality, apt to teach.",
            "1 Timothy 3:3": "Not given to wine, no striker, not greedy of filthy lucre; but patient, not a brawler, not covetous.",
            "1 Timothy 3:4": "One that ruleth well his own house, having his children in subjection with all gravity.",
            
            # Wisdom in Business
            "Proverbs 15:22": "Without counsel purposes are disappointed: but in the multitude of counsellors they are established.",
            "Proverbs 24:6": "For by wise counsel thou shalt make thy war: and in multitude of counsellors there is safety.",
            "Proverbs 11:14": "Where no counsel is, the people fall: but in the multitude of counsellors there is safety.",
            "Proverbs 20:18": "Every purpose is established by counsel: and with good advice make war.",
            "Proverbs 27:17": "Iron sharpeneth iron; so a man sharpeneth the countenance of his friend.",
            "Proverbs 13:20": "He that walketh with wise men shall be wise: but a companion of fools shall be destroyed.",
            "Proverbs 1:5": "A wise man will hear, and will increase learning; and a man of understanding shall attain unto wise counsels.",
            "Proverbs 9:9": "Give instruction to a wise man, and he will be yet wiser: teach a just man, and he will increase in learning.",
            "Proverbs 19:20": "Hear counsel, and receive instruction, that thou mayest be wise in thy latter end.",
            "Proverbs 12:15": "The way of a fool is right in his own eyes: but he that hearkeneth unto counsel is wise.",
        }
        
        return work_inspired_verses
    
    def create_body_temple_verses(self):
        """Create body as temple and health themed verses"""
        
        body_temple_verses = {
            # Body as Temple
            "1 Corinthians 6:19": "What? know ye not that your body is the temple of the Holy Ghost which is in you, which ye have of God, and ye are not your own?",
            "1 Corinthians 6:20": "For ye are bought with a price: therefore glorify God in your body, and in your spirit, which are God's.",
            "1 Corinthians 3:16": "Know ye not that ye are the temple of God, and that the Spirit of God dwelleth in you?",
            "1 Corinthians 3:17": "If any man defile the temple of God, him shall God destroy; for the temple of God is holy, which temple ye are.",
            "2 Corinthians 6:16": "And what agreement hath the temple of God with idols? for ye are the temple of the living God; as God hath said, I will dwell in them, and walk in them; and I will be their God, and they shall be my people.",
            "Ephesians 2:21": "In whom all the building fitly framed together groweth unto an holy temple in the Lord.",
            "Ephesians 2:22": "In whom ye also are builded together for an habitation of God through the Spirit.",
            "1 Peter 2:5": "Ye also, as lively stones, are built up a spiritual house, an holy priesthood, to offer up spiritual sacrifices, acceptable to God by Jesus Christ.",
            "1 Peter 2:9": "But ye are a chosen generation, a royal priesthood, an holy nation, a peculiar people; that ye should show forth the praises of him who hath called you out of darkness into his marvellous light.",
            "Revelation 3:12": "Him that overcometh will I make a pillar in the temple of my God, and he shall go no more out: and I will write upon him the name of my God, and the name of the city of my God, which is new Jerusalem, which cometh down out of heaven from my God: and I will write upon him my new name.",
            
            # Health & Healing
            "3 John 1:2": "Beloved, I wish above all things that thou mayest prosper and be in health, even as thy soul prospereth.",
            "Proverbs 17:22": "A merry heart doeth good like a medicine: but a broken spirit drieth the bones.",
            "Proverbs 14:30": "A sound heart is the life of the flesh: but envy the rottenness of the bones.",
            "Proverbs 15:30": "The light of the eyes rejoiceth the heart: and a good report maketh the bones fat.",
            "Proverbs 16:24": "Pleasant words are as an honeycomb, sweet to the soul, and health to the bones.",
            "Proverbs 12:25": "Heaviness in the heart of man maketh it stoop: but a good word maketh it glad.",
            "Proverbs 15:13": "A merry heart maketh a cheerful countenance: but by sorrow of the heart the spirit is broken.",
            "Proverbs 15:15": "All the days of the afflicted are evil: but he that is of a merry heart hath a continual feast.",
            "Proverbs 18:14": "The spirit of a man will sustain his infirmity; but a wounded spirit who can bear?",
            "Proverbs 25:25": "As cold waters to a thirsty soul, so is good news from a far country.",
            
            # Self-Control & Discipline
            "1 Corinthians 9:27": "But I keep under my body, and bring it into subjection: lest that by any means, when I have preached to others, I myself should be a castaway.",
            "Galatians 5:22": "But the fruit of the Spirit is love, joy, peace, longsuffering, gentleness, goodness, faith.",
            "Galatians 5:23": "Meekness, temperance: against such there is no law.",
            "Titus 2:12": "Teaching us that, denying ungodliness and worldly lusts, we should live soberly, righteously, and godly, in this present world.",
            "1 Peter 4:7": "But the end of all things is at hand: be ye therefore sober, and watch unto prayer.",
            "1 Peter 5:8": "Be sober, be vigilant; because your adversary the devil, as a roaring lion, walketh about, seeking whom he may devour.",
            "1 Thessalonians 5:6": "Therefore let us not sleep, as do others; but let us watch and be sober.",
            "1 Thessalonians 5:8": "But let us, who are of the day, be sober, putting on the breastplate of faith and love; and for an helmet, the hope of salvation.",
            "1 Timothy 3:2": "A bishop then must be blameless, the husband of one wife, vigilant, sober, of good behaviour, given to hospitality, apt to teach.",
            "1 Timothy 3:11": "Even so must their wives be grave, not slanderers, sober, faithful in all things.",
            
            # Physical & Spiritual Nourishment
            "Matthew 4:4": "But he answered and said, It is written, Man shall not live by bread alone, but by every word that proceedeth out of the mouth of God.",
            "John 6:35": "And Jesus said unto them, I am the bread of life: he that cometh to me shall never hunger; and he that believeth on me shall never thirst.",
            "John 6:51": "I am the living bread which came down from heaven: if any man eat of this bread, he shall live for ever: and the bread that I will give is my flesh, which I will give for the life of the world.",
            "John 4:14": "But whosoever drinketh of the water that I shall give him shall never thirst; but the water that I shall give him shall be in him a well of water springing up into everlasting life.",
            "John 7:37": "In the last day, that great day of the feast, Jesus stood and cried, saying, If any man thirst, let him come unto me, and drink.",
            "John 7:38": "He that believeth on me, as the scripture hath said, out of his belly shall flow rivers of living water.",
            "Psalm 34:8": "O taste and see that the Lord is good: blessed is the man that trusteth in him.",
            "Psalm 119:103": "How sweet are thy words unto my taste! yea, sweeter than honey to my mouth!",
            "Proverbs 24:13": "My son, eat thou honey, because it is good; and the honeycomb, which is sweet to thy taste.",
            "Proverbs 25:16": "Hast thou found honey? eat so much as is sufficient for thee, lest thou be filled therewith, and vomit it.",
            
            # Rest & Sabbath
            "Exodus 20:8": "Remember the sabbath day, to keep it holy.",
            "Exodus 20:9": "Six days shalt thou labour, and do all thy work.",
            "Exodus 20:10": "But the seventh day is the sabbath of the Lord thy God: in it thou shalt not do any work, thou, nor thy son, nor thy daughter, thy manservant, nor thy maidservant, nor thy cattle, nor thy stranger that is within thy gates.",
            "Exodus 20:11": "For in six days the Lord made heaven and earth, the sea, and all that in them is, and rested the seventh day: wherefore the Lord blessed the sabbath day, and hallowed it.",
            "Mark 2:27": "And he said unto them, The sabbath was made for man, and not man for the sabbath.",
            "Hebrews 4:9": "There remaineth therefore a rest to the people of God.",
            "Hebrews 4:10": "For he that is entered into his rest, he also hath ceased from his own works, as God did from his.",
            "Matthew 11:28": "Come unto me, all ye that labour and are heavy laden, and I will give you rest.",
            "Matthew 11:29": "Take my yoke upon you, and learn of me; for I am meek and lowly in heart: and ye shall find rest unto your souls.",
            "Psalm 23:2": "He maketh me to lie down in green pastures: he leadeth me beside the still waters.",
            
            # Strength & Endurance
            "Isaiah 40:29": "He giveth power to the faint; and to them that have no might he increaseth strength.",
            "Isaiah 40:30": "Even the youths shall faint and be weary, and the young men shall utterly fall.",
            "Isaiah 40:31": "But they that wait upon the Lord shall renew their strength; they shall mount up with wings as eagles; they shall run, and not be weary; and they shall walk, and not faint.",
            "Philippians 4:13": "I can do all things through Christ which strengtheneth me.",
            "2 Corinthians 12:9": "And he said unto me, My grace is sufficient for thee: for my strength is made perfect in weakness. Most gladly therefore will I rather glory in my infirmities, that the power of Christ may rest upon me.",
            "Ephesians 6:10": "Finally, my brethren, be strong in the Lord, and in the power of his might.",
            "Psalm 18:32": "It is God that girdeth me with strength, and maketh my way perfect.",
            "Psalm 28:7": "The Lord is my strength and my shield; my heart trusted in him, and I am helped: therefore my heart greatly rejoiceth; and with my song will I praise him.",
            "Psalm 46:1": "God is our refuge and strength, a very present help in trouble.",
            "Psalm 73:26": "My flesh and my heart faileth: but God is the strength of my heart, and my portion for ever.",
        }
        
        return body_temple_verses
    
    def integrate_new_verses(self):
        """Integrate new spiritual theme verses into the quote library"""
        
        print("[INFO] Integrating new spiritual theme verses...")
        
        # Load existing quotes
        quotes_file = "assets/quotes/quotes.json"
        with open(quotes_file, 'r', encoding='utf-8') as f:
            quotes_data = json.load(f)
        
        # Remove existing scripture quotes to avoid duplicates
        quotes_data["quotes"] = [q for q in quotes_data["quotes"] if not q.get("scripture_kjv", {}).get("enabled", False)]
        
        # Create new scripture quotes
        scripture_quotes = []
        
        for ref, text in self.new_verses.items():
            # Determine primary theme
            primary_theme = self.determine_primary_theme(ref, text)
            
            # Create scripture quote
            quote = {
                "id": f"kjv_{ref.lower().replace(' ', '_').replace(':', '_').replace('-', '_')}",
                "text": text,
                "author": "Holy Bible (KJV)",
                "work": ref,
                "year_approx": 1611,
                "source": "KJV",
                "public_domain": True,
                "license": "public_domain",
                "tags": [primary_theme, "scripture", "bible"],
                "axis": "light",
                "modes": {
                    "off_safe": False,  # Scripture is faith-only
                    "faith_ok": True
                },
                "scripture_kjv": {
                    "enabled": True,
                    "ref": ref,
                    "text": text
                },
                "attribution": "KJV",
                "checksum": ""
            }
            
            scripture_quotes.append(quote)
        
        # Add scripture quotes
        quotes_data["quotes"].extend(scripture_quotes)
        
        # Update metadata
        quotes_data["metadata"]["total_quotes"] = len(quotes_data["quotes"])
        quotes_data["metadata"]["scripture_count"] = len(scripture_quotes)
        quotes_data["metadata"]["last_updated"] = "2025-01-27T00:00:00.000Z"
        
        # Save updated quotes
        with open(quotes_file, 'w', encoding='utf-8') as f:
            json.dump(quotes_data, f, indent=2, ensure_ascii=False)
        
        print(f"[SUCCESS] Integrated {len(scripture_quotes)} new spiritual theme scripture quotes")
        print(f"[INFO] Total quotes now: {len(quotes_data['quotes'])}")
        
        return len(scripture_quotes)
    
    def determine_primary_theme(self, ref, text):
        """Determine primary theme for a verse"""
        
        text_lower = text.lower()
        
        # Spiritual warfare themes
        if any(word in text_lower for word in ["armour", "armor", "warfare", "devil", "satan", "spiritual", "wrestle", "principalities", "powers", "overcome", "conquer", "victory", "resist", "adversary"]):
            return "spiritual_warfare"
        elif any(word in text_lower for word in ["work", "labour", "labor", "business", "diligent", "sluggard", "steward", "faithful", "serve", "ministry", "counsel", "wisdom", "excellence"]):
            return "work_inspired"
        elif any(word in text_lower for word in ["temple", "body", "health", "healing", "strength", "rest", "sabbath", "sober", "temperance", "nourish", "bread", "water", "flesh", "spirit"]):
            return "body_temple"
        else:
            return "wisdom"  # Default theme
    
    def run_expansion(self):
        """Run the spiritual themes expansion"""
        
        print("SPIRITUAL THEMES EXPANSION")
        print("=" * 40)
        
        print(f"[INFO] Adding spiritual warfare verses: {len(self.create_spiritual_warfare_verses())}")
        print(f"[INFO] Adding work-inspired verses: {len(self.create_work_inspired_verses())}")
        print(f"[INFO] Adding body/temple verses: {len(self.create_body_temple_verses())}")
        print(f"[INFO] Total new verses: {len(self.new_verses)}")
        
        # Integrate new verses
        verse_count = self.integrate_new_verses()
        
        print(f"\n[SUCCESS] Spiritual themes expansion complete!")
        print(f"Added {verse_count} new scripture quotes covering:")
        print("  - Spiritual Warfare & Armor of God")
        print("  - Work Ethic & Vocation")
        print("  - Body as Temple & Health")
        
        return True

if __name__ == "__main__":
    # Create and run spiritual themes expansion
    expansion = SpiritualThemesExpansion()
    expansion.run_expansion()
